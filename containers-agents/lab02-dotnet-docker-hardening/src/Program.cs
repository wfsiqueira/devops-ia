var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var html = """
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lab 02 Concluido</title>
  <style>
    :root {
      --grad-pink: #E8386A;
      --grad-purple: #9B30CF;
      --grad-blue: #2B55DB;
      --text-main: #1E1E2E;
      --text-secondary: #6B7280;
      --surface: #FFFFFF;
      --panel: #F3F0FF;
    }

    * { box-sizing: border-box; }

    body {
      margin: 0;
      min-height: 100vh;
      font-family: "Trebuchet MS", "Segoe UI", sans-serif;
      color: var(--text-main);
      background:
        radial-gradient(circle at 15% 20%, rgba(232, 56, 106, 0.12), transparent 45%),
        radial-gradient(circle at 85% 80%, rgba(43, 85, 219, 0.15), transparent 50%),
        linear-gradient(145deg, #ffffff 0%, #f9f7ff 100%);
      display: grid;
      place-items: center;
      padding: 24px;
    }

    .card {
      width: min(840px, 100%);
      background: var(--surface);
      border-radius: 20px;
      box-shadow: 0 20px 45px rgba(30, 30, 46, 0.10);
      overflow: hidden;
      border: 1px solid rgba(124, 58, 237, 0.12);
    }

    .header-bar {
      height: 10px;
      background: linear-gradient(90deg, var(--grad-pink), var(--grad-purple), var(--grad-blue));
    }

    .content {
      padding: 52px 28px;
      text-align: center;
      background: linear-gradient(180deg, var(--surface) 0%, var(--panel) 100%);
    }

    .eyebrow {
      margin: 0 0 14px;
      font-size: 0.9rem;
      font-weight: 700;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: var(--grad-purple);
    }

    h1 {
      margin: 0;
      font-size: clamp(1.7rem, 4.8vw, 2.8rem);
      line-height: 1.2;
    }

    .highlight {
      background: linear-gradient(90deg, var(--grad-pink), var(--grad-purple), var(--grad-blue));
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
    }

    p {
      margin: 18px auto 0;
      max-width: 58ch;
      color: var(--text-secondary);
      font-size: 1.05rem;
    }
  </style>
</head>
<body>
  <main class="card">
    <div class="header-bar"></div>
    <section class="content">
      <p class="eyebrow">Containers + Kubernetes + IA</p>
      <h1>Parabens, voce concluiu o <span class="highlight">Lab 02</span> com uso de IA.</h1>
      <p>
        Sua aplicacao .NET esta em container com foco em hardening de Dockerfile,
        runtime nao-root e validacao pratica de seguranca.
      </p>
    </section>
  </main>
</body>
</html>
""";

app.MapGet("/", () => Results.Content(html, "text/html; charset=utf-8"));

app.MapGet("/healthz", () => Results.Json(new
{
  status = "ok"
}));

app.Run();
