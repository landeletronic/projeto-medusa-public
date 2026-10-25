#!/bin/sh
# =============================================================================
# setup-repo.sh — ativa as protecoes LOCAIS deste repositorio (1 vez por clone)
#
#   ./scripts/setup-repo.sh
#
# O que faz:
#   1. git config core.hooksPath .githooks   -> ativa o pre-push bloqueador
#   2. chmod +x em hooks e scripts .sh        -> portabilidade Linux/omarchy
#   3. mostra o estado das 5 camadas
#
# Windows: rode .\scripts\setup-repo.ps1 (equivalente).
# Sem este passo o hook NAO roda — mas a camada 3 (CI do GitHub) continua
# ativa, porque ela mora no servidor.
# =============================================================================
set -e

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "ERRO: rode dentro de um clone do projeto-medusa." >&2
    exit 1
}
cd "$root"

git config core.hooksPath .githooks

# sem exec-bit o git nao invoca o hook em Linux
chmod +x .githooks/* 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true

echo ""
echo "setup-repo: configuracao aplicada em $root"
echo ""
if [ -f docs/sessao/sensitive-paths.txt ]; then
    echo "  [1] manifesto .............. docs/sessao/sensitive-paths.txt (presente)"
else
    echo "  [1] manifesto .............. AUSENTE" >&2
fi
echo "  [1b] espelho no .gitignore . $(sed -n '/# --- mirror ---/,/# --- fim mirror ---/p' .gitignore | grep -c -v -e '^#' -e '^$') padroes"
echo "  [3] CI GitHub .............. .github/workflows/guard-sensitive.yml (ativo no servidor)"
echo "  [4] publicacao filtrada ..... scripts/publish-public.sh"
echo "  [5] regra do agente ......... AGENTS.md + .opencode/rules/"
echo ""

# Sanidade rapida: o manifesto tem que casar com o arquivo proibido
probe="docs/sessao/acesso-ao-host-medusa.json"
if [ -f "$probe" ]; then
    if printf '%s\n' "$probe" | git -c core.excludesFile="$root/docs/sessao/sensitive-paths.txt" \
         check-ignore --no-index --stdin >/dev/null 2>&1; then
        echo "  teste: '$probe' -> BLOQUEADO (ok)"
    else
        echo "  AVISO: '$probe' NAO foi reconhecido como sensivel. Revise o manifesto." >&2
    fi
fi
echo ""
