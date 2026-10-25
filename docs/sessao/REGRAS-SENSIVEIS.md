# REGRAS — ARQUIVOS SENSÍVEIS EM `docs/sessao/`

> **Regra nº 1:** arquivo sensível **nunca** vai para o repositório **público**.
> **Regra nº 2:** o agente **não pergunta** sobre esses arquivos — exclui e avisa em uma linha.
> **Regra nº 3:** quem mudar a lista, muda **um único arquivo**: [`sensitive-paths.txt`](./sensitive-paths.txt).

---

## 1. Por que este diretório é tratado diferente

`docs/sessao/` guarda exports de sessão de ferramentas de IA (JSON com `info` + `messages`).
Esses exports **não são documentação**: eles reproduzem saída de terminal, incluindo
chaves, IPs, nomes de host, senhas coladas em conversas e trilha de pensamento do agente.

Em 25/10/2026 foi confirmado que `acesso-ao-host-medusa.json` (131 KB) continha:

| Tipo | Exemplo encontrado |
|---|---|
| Chave de API de serviço | `API_SERVER_KEY: 02f3...8a7` |
| Senha de dashboard | `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD` |
| Segredo de dashboard | `HERMES_DASHBOARD_BASIC_AUTH_SECRET` |
| Topologia de rede | IP Tailscale `100.126.89.55`, `192.168.15.231`, host `medusa` |
| Chaves públicas SSH | `ssh-ed25519 AAAAC3...`, `ssh-rsa AAAAB3...` |
| E-mails e rotinas de acesso | usuário, horário e origem de login |

Esse material esteve **público** de 21 a 25/10/2026. Trate tudo o que está lá como
**comprometido**: expurgar o histórico não desfaz uma possível cópia já baixada —
**rotacione as credenciais**.

---

## 2. As 5 camadas que aplicam esta regra

| # | Camada | Arquivo | Onde vale | Contornável? |
|---|---|---|---|---|
| 1 | Não rastrear | `.gitignore` | qualquer máquina | sim (`git add -f`) |
| 2 | Não enviar | `.githooks/pre-push` | qualquer máquina, após setup | sim (`--no-verify`) |
| 3 | **Não aceitar no servidor** | `.github/workflows/guard-sensitive.yml` | **GitHub, sempre** | **não** |
| 4 | Publicar filtrado | `scripts/publish-public.sh` / `.ps1` | qualquer máquina | — |
| 5 | Agente não pergunta | `AGENTS.md` + `.opencode/rules/` | qualquer agente, qualquer SO | — |

A **camada 3 é a autoridade**. As outras são conforto: se qualquer uma falhar, o
GitHub recusa o conteúdo e o workflow fica vermelho.

---

## 3. O que fazer (e o que nunca fazer)

### ✅ Publicar documentação nova no repositório público

```bash
# Linux / omarchy (Arch)
./scripts/setup-repo.sh      # só na primeira vez após clonar
./scripts/publish-public.sh

# Windows (PowerShell)
.\scripts\setup-repo.ps1     # só na primeira vez após clonar
.\scripts\publish-public.ps1
```

O script de publicação **copia o histórico para um clone temporário, remove os
caminhos do manifesto e só então envia**. Arquivo sensível não é "esquecido" no
público — ele **não existe** no repositorio publico, em nenhum commit.

### ❌ Nunca

```bash
git push public main          # bloqueado pelo hook (camada 2)
git push public main --no-verify   # aceito pelo git, REJEITADO pelo GitHub (camada 3)
git add -f docs/sessao/acesso-ao-host-medusa.json
git commit -m "..." -- public   # o arquivo continua no privado; nunca o exporte
```

### Adicionar um arquivo novo à lista de proibidos

1. Edite `docs/sessao/sensitive-paths.txt` (caminho exato ou `glob:`).
2. Se ele já estiver versionado: apague de **todo** o histórico público
   (`git filter-repo --invert-paths --path <caminho>`) e **rotacione** o conteúdo.
3. Commit + `./scripts/publish-public.sh`.
4. Não precisa alterar mais nada — hook, CI e agente leem o mesmo manifesto.

---

## 4. Comportamento esperado do agente (opencode e afins)

Quando um caminho do manifesto aparecer em `git status`, `git add`, diff ou pedido do usuário:

- **Não** perguntar se deve commitar, publicar ou "limpar".
- **Não** exibir o conteúdo, trechos, chaves ou IP do arquivo.
- **Não** rodar `git push public`.
- **Fazer:** remover do staging (`git restore --staged <caminho>`), deixar fora do commit,
  e responder em **uma linha**: `arquivo sensível <caminho> — fora do commit; publicação ignorada.`
- Se o usuário insistir em publicar: recusar e apontar para este documento.

Isso está registrado em [`AGENTS.md`](../../AGENTS.md) e em `.opencode/rules/arquivos-sensiveis.md`,
que são carregados automaticamente em qualquer clone, em qualquer sistema operacional.

---

## 5. Verificação rápida (qualquer máquina)

```bash
# algum arquivo proibido seria aceito pelo gitignore?
printf '%s\n' docs/sessao/acesso-ao-host-medusa.json | git check-ignore --no-index --stdin -v

# o manifesto está completo?
cat docs/sessao/sensitive-paths.txt

# o hook está ativo?
git config --get core.hooksPath        # esperado: .githooks

# o repositório público está limpo em TODO o histórico?
git rev-list --objects --all | grep -F acesso-ao-host   # esperado: nada
```
