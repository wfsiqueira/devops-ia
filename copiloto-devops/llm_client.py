from importlib import import_module
from typing import Any

from dotenv import load_dotenv

load_dotenv()


def get_llm(temperature: float = 0) -> Any:
    """Cria o cliente do LLM usado em todos os labs do projeto."""
    try:
        ChatGroq = import_module("langchain_groq").ChatGroq
    except ModuleNotFoundError as exc:
        if exc.name != "langchain_groq":
            raise
        raise RuntimeError(
            "Dependência ausente: instale 'langchain-groq' para usar o cliente LLM."
        ) from exc

    return ChatGroq(model="openai/gpt-oss-120b", temperature=temperature)
