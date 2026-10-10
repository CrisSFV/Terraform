const http = require("node:http");

const port = Number(process.env.PORT || 8080);
const hostname = "0.0.0.0";

const html = `<!doctype html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Integradora | Azure</title>
    <style>
      body { margin: 0; font-family: Segoe UI, Arial, sans-serif; background: #f4f7fb; color: #172b4d; }
      main { max-width: 760px; margin: 10vh auto; padding: 2.5rem; background: white; border-radius: 16px; box-shadow: 0 8px 30px #172b4d22; }
      h1 { color: #0078d4; margin-top: 0; }
      li { margin: .7rem 0; }
      .ok { color: #107c10; font-weight: 600; }
    </style>
  </head>
  <body>
    <main>
      <h1>Aplicación Integradora</h1>
      <p class="ok">Aplicación publicada correctamente en Azure App Service.</p>
      <ul>
        <li>Infraestructura administrada con Terraform</li>
        <li>App Service Linux con Node.js 20</li>
        <li>Red virtual y servicios privados habilitados</li>
      </ul>
    </main>
  </body>
</html>`;

const server = http.createServer((request, response) => {
  if (request.url === "/health") {
    response.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
    response.end(JSON.stringify({ status: "ok" }));
    return;
  }

  response.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  response.end(html);
});

server.listen(port, hostname, () => {
  console.log(`Server listening on http://${hostname}:${port}`);
});
