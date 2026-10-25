# =============================================================================
# publish-public.ps1 — wrapper Windows para scripts/publish-public.sh
#
#   .\scripts\publish-public.ps1 [branch]     (padrao: main)
#
# A logica vive em UM so lugar (scripts/publish-public.sh, POSIX sh) para que
# Windows e omarchy/Arch nao divirjam. Aqui so localizamos o sh do Git for
# Windows e repassamos os argumentos.
# =============================================================================
$ErrorActionPreference = "Stop"

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) {
    Write-Error "ERRO: rode dentro de um clone do projeto-medusa."
    exit 1
}
Set-Location $root

$sh = $null
foreach ($cand in @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "$env:ProgramFiles\Git\usr\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "$env:LocalAppData\Programs\Git\bin\bash.exe"
    )) {
    if ($cand -and (Test-Path $cand)) { $sh = $cand; break }
}
if (-not $sh) {
    $cmd = Get-Command bash -ErrorAction SilentlyContinue
    if ($cmd) { $sh = $cmd.Source }
}
if (-not $sh) {
    Write-Error ("bash.exe nao encontrado. Instale o Git for Windows ou rode " +
        "direto: bash scripts/publish-public.sh")
    exit 1
}

# caminho POSIX (C:\x\y -> /c/x/y)
$posixRoot = ($root -replace '\\', '/').Trim('/')
if ($posixRoot -match '^[A-Za-z]:') { $posixRoot = '/' + ($posixRoot -replace '^([A-Za-z]):', '$1') }
$script = "$posixRoot/scripts/publish-public.sh"

$argsList = @()
if ($args.Count -gt 0) { $argsList = @($args) }

& $sh -lc "cd '$posixRoot' && sh scripts/publish-public.sh $($argsList -join ' ')"
exit $LASTEXITCODE
