#!/bin/sh
# =============================================================================
# publish-public.sh — PUBLICACAO SEGURA no repositorio PUBLICO
#
#   ./scripts/publish-public.sh [branch]     (padrao: main)
#
# Por que existe: o repositorio PRIVADO guarda arquivos sensiveis que NUNCA
# podem ir para o publico. Publicar com `git push public main` depende de
# memoria humana; este script NAO depende — ele constroi o envio a partir de
# um clone temporario e APAGA do historico tudo que esta no manifesto
# (docs/sessao/sensitive-paths.txt) antes de enviar.
#
# Fluxo:
#   [1] clona --bare para um diretorio temporario
#   [2] git filter-repo remove cada caminho do manifesto (inclusive em commits
#       antigos — e la que o GitHub guarda os segredos)
#   [3] verificacao: nenhum objeto restante casa com o manifesto
#   [4] push --force (o historico e reescrito por definicao)
#   [5] git fetch para sincronizar refs/remotes/public/*
#
# Requisito: git-filter-repo
#   omarchy/Arch : sudo pacman -S git-filter-repo
#   Debian/Ubuntu: sudo apt install git-filter-repo
#   Windows      : pip install git-filter-repo
#
# Windows: rode .\scripts\publish-public.ps1 (encaminha para este script).
# =============================================================================
set -eu

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "ERRO: rode dentro de um clone do projeto-medusa." >&2
    exit 1
}
cd "$root"

BRANCH="${1:-main}"
MANIFEST="docs/sessao/sensitive-paths.txt"

PUBLIC_URL=$(git remote get-url public 2>/dev/null || true)
if [ -z "$PUBLIC_URL" ]; then
    PUBLIC_URL="https://github.com/landeletronic/projeto-medusa-public.git"
fi

if ! git rev-parse --verify --quiet "$BRANCH" >/dev/null; then
    echo "ERRO: branch local '$BRANCH' nao existe." >&2
    exit 1
fi

if [ ! -f "$MANIFEST" ]; then
    echo "ERRO: manifesto ausente ($MANIFEST)." >&2
    echo "      Sem ele nao ha como garantir a filtragem. Abortando." >&2
    exit 1
fi

# --- [0] git-filter-repo ------------------------------------------------------
if ! git filter-repo --version >/dev/null 2>&1; then
    echo "ERRO: git-filter-repo nao encontrado." >&2
    echo "" >&2
    echo "  omarchy/Arch : sudo pacman -S git-filter-repo" >&2
    echo "  Debian/Ubuntu: sudo apt install git-filter-repo" >&2
    echo "  Windows      : pip install git-filter-repo" >&2
    exit 1
fi

# --- [1] monta os argumentos de filtragem a partir do manifesto ----------------
set --   # limpa os parametros posicionais
while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        ''|'#'*) continue ;;
        glob:*)  set -- "$@" --path-glob "${line#glob:}" ;;
        *)       set -- "$@" --path-glob "$line" ;;
    esac
done < "$MANIFEST"

if [ "$#" -eq 0 ]; then
    echo "ERRO: manifesto vazio — nada seria filtrado. Abortando." >&2
    exit 1
fi

echo "publish-public: filtrando $# padroes do manifesto"

tmp=$(mktemp -d 2>/dev/null || mktemp -d -t medusa-public)
trap 'rm -rf "$tmp"' EXIT INT TERM

# --- [2] clone + filtragem ----------------------------------------------------
git clone --quiet --bare "$root" "$tmp/mirror.git"
git -C "$tmp/mirror.git" filter-repo --invert-paths "$@" --force >/dev/null

# --- [3] verificacao: nada sensivel sobrou no resultado -----------------------
leftovers=$(
    git -C "$tmp/mirror.git" rev-list --objects --all 2>/dev/null \
        | sed 's/^[0-9a-f]\{7,\} //' \
        | grep -v '^$' \
        | sort -u \
        | git -C "$tmp/mirror.git" -c core.excludesFile="$root/$MANIFEST" \
            check-ignore --no-index --stdin -v 2>/dev/null || true
)

if [ -n "$leftovers" ]; then
    echo "" >&2
    echo "ERRO CRITICO: filtragem incompleta. Nada foi publicado." >&2
    echo "$leftovers" >&2
    exit 1
fi

# --- [4] o que sai da arvore (transparencia) ----------------------------------
echo ""
echo "  removido da publicacao:"
comm -23 \
    <(git ls-tree -r --name-only "$BRANCH" | sort) \
    <(git -C "$tmp/mirror.git" ls-tree -r --name-only "refs/heads/$BRANCH" 2>/dev/null | sort) \
    | sed 's/^/    - /'
echo ""

# --- [5] envio ----------------------------------------------------------------
# --no-verify: o hook local veria o mirror temporario (sem os nossos hooks);
# a garantia real aqui e a filtragem acima + a camada 3 (CI do GitHub).
echo "publish-public: enviando para $PUBLIC_URL"
git -C "$tmp/mirror.git" push --no-verify --force \
    "$PUBLIC_URL" "refs/heads/$BRANCH:refs/heads/$BRANCH"

# --- [6] sincroniza o remote-tracking local -----------------------------------
git fetch --quiet public 2>/dev/null || true

echo ""
echo "OK: '$BRANCH' publicado em $PUBLIC_URL"
echo "    Sincronizado: $(git rev-parse --short "refs/remotes/public/$BRANCH" 2>/dev/null || echo 'refs/remotes/public/'"$BRANCH")"
echo "    Verificacao servidor-side: GitHub Actions -> guard-sensitive"
echo ""
