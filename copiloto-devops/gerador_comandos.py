from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from llm_client import get_llm

llm = get_llm()

prompt = ChatPromptTemplate.from_messages([
    (
        "system",
        "Voce e um especialista em Linux e shell. Dado um pedido em portugues, "
        "responda APENAS com o comando de shell equivalente, em uma unica linha, "
        "sem explicacao, sem markdown e sem crases.",
    ),
    ("human", "{pedido}"),
])

chain = prompt | llm | StrOutputParser()

PEDIDOS = [
    "quero listar os 10 arquivos maiores desta pasta",
    "quero ver quais processos estao usando mais memoria",
    "quero encontrar todos os arquivos .log modificados nas ultimas 24 horas",
]

if __name__ == "__main__":
    for pedido in PEDIDOS:
        comando = chain.invoke({"pedido": pedido})
        print(f"[{pedido}]\n$ {comando}\n")
