from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from llm_client import get_llm

llm = get_llm()

prompt = ChatPromptTemplate.from_template(
    "Explique em uma frase, de forma simples, o que e {termo} no contexto de {area}."
)

chain = prompt | llm | StrOutputParser()

perguntas = [
    {"termo": "DevOps", "area": "engenharia de software"},
    {"termo": "Pull Request", "area": "controle de versao"},
    {"termo": "container", "area": "infraestrutura"},
]

for entrada in perguntas:
    resposta = chain.invoke(entrada)
    print(f"[{entrada['termo']}] {resposta}\n")
