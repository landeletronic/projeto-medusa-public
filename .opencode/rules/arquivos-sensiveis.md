# Arquivos sensíveis — não pergunte, não publique

Regra permanente do projeto-medusa para **o opencode em qualquer versão, em
qualquer máquina** (Windows, omarchy/Arch, VM). Espelhada em `AGENTS.md` na
raiz para outros agentes.

## Lista canônica

`docs/sessao/sensitive-paths.txt` — mesmo conteúdo do bloco `mirror` em `.gitignore`.
Hoje inclui, entre outros:

- `docs/sessao/acesso-ao-host-medusa.json`
- `acesso-ao-host-medusa.json`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.ppk`, `id_rsa*`, `id_ed25519*`
- `*.env`, `.env*`, `secrets/*`, `*_password`, `*password*.txt`

## Comportamento exigido

Ao detectar qualquer caminho da lista em `git status`, staging, diff, push ou
pedido do usuário:

1. **Não pergunte** se deve commitar, publicar, "limpar" ou exibir.
2. **Não exiba** conteúdo, trechos, chaves, IPs ou senhas.
3. **Não rode** `git push public` nem `git add -f`.
4. Remova do staging: `git restore --staged <caminho>`.
5. Responda **uma linha**: `arquivo sensível <caminho> — fora do commit; publicação ignorada.`
6. Se pedirem publicação mesmo assim: recuse e cite
   `docs/sessao/REGRAS-SENSIVEIS.md`.

## Remoto

- `origin` → `projeto-medusa` (**privado**): o arquivo sensível é legítimo lá.
- `public` → `projeto-medusa-public` (**público**): nunca direto.
  Publicação = `./scripts/publish-public.sh` (filtra o histórico).

## Setup em clone novo

`git config --get core.hooksPath` ≠ `.githooks` → rode `./scripts/setup-repo.sh`
(Linux) ou `.\scripts\setup-repo.ps1` (Windows), sem perguntar.
