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
| 3 | **Detectar no servidor** | `.github/workflows/guard-sensitive.yml` | **GitHub, sempre** | push direto entra, mas o **run fica vermelho** |
| 4 | Publicar filtrado | `scripts/publish-public.sh` / `.ps1` | qualquer máquina | — |
| 5 | Agente não pergunta | `AGENTS.md` + `.opencode/rules/` | qualquer agente, qualquer SO | — |

**O que a camada 3 faz e o que ela não faz.** Ela roda no GitHub, não na sua
máquina: um push feito com `--no-verify`, de outra máquina ou por outro agente
é **recebido pelo GitHub e imediatamente marcado como falha** (run vermelho,
com `##[error] commit <sha> contem arquivo sensivel` e a lista de commits).
Não depende de nada instalado localmente.

O que ela **não** faz sozinha: impedir que o conteúdo chegue — o push já
aconteceu quando o check roda. Isso é limitação da planta gratuita do GitHub
sem fluxo de PR. Duas defesas cobrem isso:

- **quem envia só envia via `scripts/publish-public.*`** (camada 4), que filtra
  o histórico **antes** do push — é o caminho sancionado;
- **optional, hard gate:** regra `pull_request` na ruleset do GitHub torna o
  `main` imutável fora de PR, e o check passa a valer como trava de merge
  (exige mudar o fluxo de trabalho — decidir caso a caso).

A **ruleset ativa** hoje (`25828972`) impõe no servidor: proibição de **delete**
do `main` e de **force-push** (`non_fast_forward`). Não usei
`required_status_checks` porque ele congela o branch: o check só existe depois
do push, e o GitHub recusa o próprio push legítimo.

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
git push public main --no-verify   # passa pelo git -> run do CI fica VERMELHO
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
