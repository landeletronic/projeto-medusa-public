# =============================================================================
# setup-repo.ps1 — ativa as protecoes LOCAIS no Windows (1 vez por clone)
#
#   .\scripts\setup-repo.ps1
#
# Equivalente a ./scripts/setup-repo.sh (Linux/omarchy).
# =============================================================================
$ErrorActionPreference = "Stop"

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) {
    Write-Error "ERRO: rode dentro de um clone do projeto-medusa."
    exit 1
}
Set-Location $root

# [2] ativa o hook pre-push bloqueador (sem isto o hook NAO executa)
git config core.hooksPath .githooks

Write-Host ""
Write-Host "setup-repo: configuracao aplicada em $root"
Write-Host ""
Write-Host "  [1] .gitignore ............. espelho do manifesto ativo"
Write-Host "  [2] core.hooksPath ......... $(git config --get core.hooksPath)"
Write-Host "  [3] CI GitHub .............. .github/workflows/guard-sensitive.yml (ativo no servidor)"
Write-Host "  [4] publicacao filtrada ..... scripts\publish-public.ps1"
Write-Host "  [5] regra do agente ......... AGENTS.md + .opencode\rules\"
Write-Host ""

# Sanidade: o manifesto tem que casar com o arquivo proibido
$probe = "docs/sessao/acesso-ao-host-medusa.json"
if (Test-Path $probe) {
    $out = git -c core.excludesFile="$root/docs/sessao/sensitive-paths.txt" `
                check-ignore --no-index --stdin -v 2>$null
    if ($LASTEXITCODE -eq 0 -and $out) {
        Write-Host "  teste: '$probe' -> BLOQUEADO (ok)"
    } else {
        Write-Warning "'$probe' NAO foi reconhecido como sensivel. Revise o manifesto."
    }
}
Write-Host ""
