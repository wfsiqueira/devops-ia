from llm_client import get_llm

llm = get_llm()

resposta = llm.invoke("Explique em uma frase o que e DevOps.")
print(resposta.content)
