#!/bin/sh
# =============================================================================
# selftest.sh — valida as 5 camadas de protecao contra dados sensiveis
#
#   ./scripts/selftest.sh          (Linux/omarchy:  sh scripts/selftest.sh)
#   Windows: "C:\Program Files\Git\bin\bash.exe" scripts/selftest.sh
#
# NAO altera nada: apenas verifica e imprime PASS/FAIL por camada.
# =============================================================================
pass=0
fail=0

ok()   { echo "  [PASS] $1"; pass=$((pass + 1)); }
bad()  { echo "  [FAIL] $1"; fail=$((fail + 1)); }

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "ERRO: rode dentro do repositorio projeto-medusa." >&2
    exit 1
}
cd "$root" || exit 1

MANIFEST="$root/docs/sessao/sensitive-paths.txt"
PROBE="docs/sessao/acesso-ao-host-medusa.json"

echo ""
echo "=== selftest — protecao de dados sensiveis ================================"

# --- CAMADA 1: .gitignore impede git add --------------------------------------
echo ""
echo "Camada 1 — .gitignore (nao rastrear)"
if [ -f "$PROBE" ]; then
    if printf '%s\n' "$PROBE" | git check-ignore --no-index --stdin >/dev/null 2>&1; then
        ok "'$PROBE' casado pelo .gitignore"
    else
        bad "'$PROBE' NAO casado pelo .gitignore"
    fi
else
    ok "arquivo de teste inexistente no working tree (nada a bloquear)"
fi
if printf '%s\n' "qualquer.pem" | git check-ignore --no-index --stdin >/dev/null 2>&1; then
    ok "curinga '*.pem' ativo"
else
    bad "curinga '*.pem' nao casou"
fi
if printf '%s\n' "README.md" | git check-ignore --no-index --stdin >/dev/null 2>&1; then
    bad "falso positivo: README.md marcado como sensivel"
else
    ok "sem falso positivo em README.md"
fi

# --- CAMADA 2: hook pre-push instalado ----------------------------------------
echo ""
echo "Camada 2 — hook pre-push"
hp=$(git config --get core.hooksPath || true)
if [ "$hp" = ".githooks" ]; then
    ok "core.hooksPath = .githooks"
else
    bad "core.hooksPath = '${hp:-<vazio>}' (esperado .githooks) -> rode scripts/setup-repo.sh"
fi
if [ -f .githooks/pre-push ]; then
    ok ".githooks/pre-push existe"
    if [ -x .githooks/pre-push ]; then
        ok ".githooks/pre-push tem permissao de execucao"
    else
        bad ".githooks/pre-push SEM permissao de execucao (chmod +x)"
    fi
    if sh -n .githooks/pre-push 2>/dev/null; then
        ok "sintaxe POSIX sh valida"
    else
        bad "erro de sintaxe em .githooks/pre-push"
    fi
else
    bad ".githooks/pre-push ausente"
fi

# --- CAMADA 2b: o hook de fato bloqueia ---------------------------------------
echo ""
echo "Camada 2b — simulacao de push bloqueado"
if [ -f .githooks/pre-push ] && [ -n "$PROBE" ]; then
    # simula: remoto publico, ref nova apontando para um commit que CONTÉM o arquivo
    victim=$(git log --all --format=%H -1 -- "$PROBE" 2>/dev/null || true)
    if [ -z "$victim" ]; then
        victim=$(git rev-parse HEAD)
    fi
    zero="0000000000000000000000000000000000000000"
    out=$(printf 'refs/heads/main %s refs/heads/main %s\n' "$victim" "$zero" \
          | sh .githooks/pre-push public https://github.com/landeletronic/projeto-medusa-public.git 2>&1)
    rc=$?
    if [ "$rc" -ne 0 ]; then
        ok "push para remote PUBLICO foi bloqueado (exit $rc)"
    else
        bad "push para remote PUBLICO passou livre!"
    fi
    out2=$(printf 'refs/heads/main %s refs/heads/main %s\n' "$victim" "$zero" \
          | sh .githooks/pre-push origin https://github.com/landeletronic/projeto-medusa.git 2>&1)
    rc2=$?
    if [ "$rc2" -eq 0 ]; then
        ok "push para o remote PRIVADO continua liberado"
    else
        bad "push para o remote PRIVADO foi bloqueado indevidamente"
    fi
else
    bad "nao foi possivel simular (hook ou arquivo de teste ausente)"
fi

# --- CAMADA 3: workflow de CI -------------------------------------------------
echo ""
echo "Camada 3 — CI no GitHub (incontornavel)"
if [ -f .github/workflows/guard-sensitive.yml ]; then
    ok ".github/workflows/guard-sensitive.yml existe"
else
    bad "workflow guard-sensitive ausente"
fi
if [ -f "$MANIFEST" ]; then
    manifesto=$(grep -v -e '^#' -e '^$' "$MANIFEST" | sed 's/^glob://' | sort -u)
    espelho=$(sed -n '/^# --- mirror ---$/,/^# --- fim mirror ---$/p' .gitignore \
             | grep -v -e '^#' -e '^$' | sort -u)
    if [ "$manifesto" = "$espelho" ]; then
        ok ".gitignore (mirror) sincronizado com o manifesto"
    else
        bad ".gitignore (mirror) DIVERGIU do manifesto — CI vai falhar"
        _a=$(mktemp 2>/dev/null || echo /tmp/st.a); _b=$(mktemp 2>/dev/null || echo /tmp/st.b)
        printf '%s\n' "$espelho" > "$_a"; printf '%s\n' "$manifesto" > "$_b"
        diff "$_a" "$_b" 2>/dev/null || true
        rm -f "$_a" "$_b"
    fi
else
    bad "manifesto ausente: $MANIFEST"
fi

# --- CAMADA 4: publicacao filtrada --------------------------------------------
echo ""
echo "Camada 4 — publicacao filtrada"
if git filter-repo --version >/dev/null 2>&1; then
    ok "git-filter-repo instalado ($(git filter-repo --version 2>/dev/null | head -1))"
else
    bad "git-filter-repo AUSENTE (Arch: pacman -S git-filter-repo / Debian: apt install / Win: pip install)"
fi
for f in scripts/publish-public.sh scripts/publish-public.ps1; do
    if [ -f "$f" ]; then ok "$f existe"; else bad "$f ausente"; fi
done

# --- CAMADA 5: regra do agente -------------------------------------------------
echo ""
echo "Camada 5 — regra do agente (nao perguntar)"
for f in AGENTS.md .opencode/rules/arquivos-sensiveis.md docs/sessao/REGRAS-SENSIVEIS.md docs/sessao/sensitive-paths.txt; do
    if [ -f "$f" ]; then ok "$f existe"; else bad "$f ausente"; fi
done

# --- ESTADO DOS REMOTES --------------------------------------------------------
echo ""
echo "Remotes"
echo "  origin (privado) : $(git remote get-url origin 2>/dev/null || echo '<ausente>')"
echo "  public (publico) : $(git remote get-url public 2>/dev/null || echo '<ausente>')"

echo ""
echo "==========================================================================="
echo "  resultado: $pass PASS / $fail FAIL"
echo "==========================================================================="
echo ""

[ "$fail" -eq 0 ] || exit 1
exit 0
