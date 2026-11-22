from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from llm_client import get_llm

llm = get_llm()

prompt = ChatPromptTemplate.from_messages([
    (
        "system",
        "Voce e um engenheiro de DevOps experiente. Explique logs de erro em "
        "portugues simples e direto, e termine sugerindo uma causa provavel.",
    ),
    ("human", "{log}"),
])

chain = prompt | llm | StrOutputParser()

LOGS = {
    "python_connection_error": """
Traceback (most recent call last):
  File "app.py", line 12, in <module>
    resposta = requests.get(url, timeout=2)
  File "/usr/lib/python3/requests/api.py", line 73, in get
    return request("get", url, params=params, **kwargs)
ConnectionError: HTTPConnectionPool(host='localhost', port=8080): Max retries exceeded with url: /healthz
""",
    "systemd_service_failed": """
$ systemctl status nginx
● nginx.service - A high performance web server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled)
     Active: failed (Result: exit-code) since Sat 2026-07-11 10:02:15 UTC; 5s ago
    Process: 1842 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=1/FAILURE)
""",
    "k8s_crashloop": """
$ kubectl describe pod api-7f9c8d-abc12
...
  Warning  BackOff  10s (x5 over 40s)  kubelet  Back-off restarting failed container
  Normal   Pulled   41s                kubelet  Successfully pulled image "api:latest"
State:      Waiting
  Reason:   CrashLoopBackOff
Last State: Terminated
  Reason:   Error
  Exit Code:  1
""",
}

if __name__ == "__main__":
    for nome, log in LOGS.items():
        print(f"=== {nome} ===")
        print(chain.invoke({"log": log}))
        print()
