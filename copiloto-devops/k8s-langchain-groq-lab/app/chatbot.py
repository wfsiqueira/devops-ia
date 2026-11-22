#!/usr/bin/env python3
"""
K8s Monitoring & Troubleshooting Chatbot
Uses LangChain + Groq for intelligent infrastructure assistance with kubectl execution
"""

import os
import subprocess
import json
import re
from flask import Flask, request, jsonify, send_from_directory
from langchain_groq import ChatGroq
from langchain.schema import AIMessage, HumanMessage, SystemMessage

app = Flask(__name__, static_folder='static')

# Initialize Groq LLM
llm = ChatGroq(
    model="openai/gpt-oss-120b",
    temperature=0.3,
    groq_api_key=os.getenv("GROQ_API_KEY")
)

def execute_kubectl(command: str) -> str:
    """
    Executa comandos kubectl no cluster Kubernetes.

    Args:
        command: O comando kubectl sem o 'kubectl' no início. Ex: "get pods -n default"

    Returns:
        O output do comando kubectl ou mensagem de erro
    """
    # Lista de comandos permitidos (somente leitura)
    allowed_commands = [
        'get', 'describe', 'logs', 'top', 'explain',
        'cluster-info', 'api-resources', 'api-versions'
    ]

    # Extrair o primeiro argumento (comando principal)
    cmd_parts = command.strip().split()
    if not cmd_parts:
        return "Erro: Comando vazio"

    main_command = cmd_parts[0]

    # Verificar se o comando é permitido
    if main_command not in allowed_commands:
        return f"Erro: Comando '{main_command}' não permitido. Comandos permitidos: {', '.join(allowed_commands)}"

    try:
        # Executar comando kubectl
        result = subprocess.run(
            ['kubectl'] + cmd_parts,
            capture_output=True,
            text=True,
            timeout=10
        )

        # Remove códigos ANSI de cor (aparecem como sujeira no frontend)
        clean = lambda text: re.sub(r'\x1b\[[0-9;]*m', '', text)

        if result.returncode == 0:
            return clean(result.stdout) if result.stdout else "Comando executado com sucesso (sem output)"
        else:
            return f"Erro ao executar comando:\n{clean(result.stderr)}"

    except subprocess.TimeoutExpired:
        return "Erro: Comando expirou após 10 segundos"
    except Exception as e:
        return f"Erro ao executar comando: {str(e)}"
    
# System prompt for K8s troubleshooting assistant
SYSTEM_PROMPT = """Você é um assistente especialista em infraestrutura Kubernetes, focado em monitoramento e troubleshooting.

Você trabalha em CICLOS de investigação (como um agente):

1. Para consultar o cluster, responda com o comando no formato: [KUBECTL: comando]
2. Você receberá o RESULTADO do comando e poderá pedir o próximo comando
3. Quando tiver informação suficiente, responda com a explicação final em texto, SEM usar [KUBECTL: ...]

Comandos permitidos: get, describe, logs, top, explain, cluster-info, api-resources, api-versions

REGRAS:
- Responda SEMPRE em português brasileiro
- NUNCA invente nomes de pods ou recursos. Se não souber o nome, descubra primeiro com um comando get
- Peça UM comando por vez e aguarde o resultado antes de decidir o próximo
- Seja conciso mas completo na explicação final

Exemplo (pergunta: "mostre os logs do pod mais recente"):
- Ciclo 1: [KUBECTL: get pods -n k8s-chatbot --sort-by=.metadata.creationTimestamp]
- Ciclo 2 (após ver os nomes reais): [KUBECTL: logs k8s-chatbot-abc123 -n k8s-chatbot --tail=50]
- Ciclo 3: explicação final em texto
"""

# Limite de ciclos do loop agêntico (evita loop infinito)
MAX_CICLOS = 5

# Padrão que identifica um pedido de comando na resposta do LLM
KUBECTL_PATTERN = r'\[KUBECTL:\s*([^\]]+)\]'

@app.route('/')
def index():
    """Serve frontend"""
    return send_from_directory('static', 'index.html')

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "k8s-chatbot"}), 200

@app.route('/ready', methods=['GET'])
def ready():
    """Readiness probe endpoint"""
    try:
        # Test if Groq API key is configured
        if not os.getenv("GROQ_API_KEY"):
            return jsonify({"status": "not ready", "reason": "GROQ_API_KEY not configured"}), 503
        return jsonify({"status": "ready"}), 200
    except Exception as e:
        return jsonify({"status": "not ready", "reason": str(e)}), 503

@app.route('/chat', methods=['POST'])
def chat():
    """Chat endpoint com loop agêntico: executa → observa → decide → explica"""
    try:
        data = request.get_json()
        question = data.get('question', '')

        if not question:
            return jsonify({"error": "No question provided"}), 400

        # Histórico da conversa entre o backend e o LLM
        messages = [
            SystemMessage(content=SYSTEM_PROMPT),
            HumanMessage(content=question)
        ]
        terminal_blocks = []  # outputs de kubectl para mostrar ao usuário

        # Loop agêntico: o LLM pede comandos, vê os resultados e decide o próximo passo
        for _ in range(MAX_CICLOS):
            answer = llm.invoke(messages).content
            commands = re.findall(KUBECTL_PATTERN, answer)

            # Sem comandos = o LLM terminou a investigação e deu a explicação final
            if not commands:
                break

            # Executa os comandos pedidos e guarda os outputs
            results = []
            for cmd in commands:
                cmd = cmd.strip()
                output = execute_kubectl(cmd)
                results.append(f"$ kubectl {cmd}\n{output.rstrip()}")
            terminal_blocks.extend(results)

            # Devolve os resultados ao LLM para ele decidir o próximo passo
            messages.append(AIMessage(content=answer))
            messages.append(HumanMessage(content=(
                "Resultado dos comandos:\n\n" + "\n\n".join(results) +
                "\n\nSe precisar de mais informações, responda com outro [KUBECTL: comando]. "
                "Caso contrário, dê a explicação final em português, sem usar [KUBECTL: ...]."
            )))

        # Resposta final: blocos de terminal + explicação (sem marcadores residuais)
        explanation = re.sub(KUBECTL_PATTERN, '', answer).strip()
        if terminal_blocks:
            blocks = "\n\n".join(f"```\n{b}\n```" for b in terminal_blocks)
            answer = f"{blocks}\n\n{explanation}"
        else:
            answer = explanation

        return jsonify({
            "question": question,
            "answer": answer,
            "model": "llama-3.3-70b-versatile"
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/examples', methods=['GET'])
def examples():
    """Return example questions"""
    return jsonify({
        "examples": [
            "Liste os pods do namespace k8s-chatbot",
            "Mostre os logs do pod mais recente",
            "Quais são os deployments rodando no cluster?",
            "Mostre o uso de recursos dos nodes",
            "Descreva o pod k8s-chatbot",
            "Liste todos os namespaces",
            "Quais services existem?",
            "Mostre os eventos recentes"
        ]
    }), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)