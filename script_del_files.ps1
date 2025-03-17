# Solicita execução como Administrador
$adminCheck = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Definir os caminhos remotos a serem verificados
$paths = @(
    "\\10.237.10.36\c$\Users\AUTONHSOB\Desktop",
    "\\10.237.10.36\c$\Users\AUTONHSOB\Documents",
    "\\10.237.10.36\c$\Users\AUTONHSOB\Downloads",
    "\\10.237.10.36\c$\Users\AUTONHSOB\Pictures",
    "\\10.237.10.37\c$\Users\AUTONHSOB\Desktop",
    "\\10.237.10.37\c$\Users\AUTONHSOB\Documents",
    "\\10.237.10.37\c$\Users\AUTONHSOB\Downloads",
    "\\10.237.10.37\c$\Users\AUTONHSOB\Pictures",
    "\\10.237.10.36\scaner-auto"
)

# Definir as extensões dos arquivos a serem pesquisados
$extensions = @("*.doc", "*.docx", "*.odt", "*.rtf", "*.txt", "*.md", "*.wpd", "*.pdf", "*.ps", "*.xps", 
                "*.xls", "*.xlsx", "*.ods", "*.csv", "*.tsv", "*.ppt", "*.pptx", "*.odp", "*.key", "*.mdb", 
                "*.accdb", "*.sql", "*.dbf", "*.db", "*.epub", "*.mobi", "*.azw", "*.azw3", "*.fb2", "*.tex", 
                "*.bib", "*.ris", "*.ai", "*.psd", "*.indd", "*.pdfa", "*.xml", "*.json", "*.yaml", 
                "*.zip", "*.rar", "*.7z", "*.tar", "*.gz", "*.bz2", "*.xz", "*.tar.gz", "*.tar.bz2", "*.tar.xz")

function Mostrar-Menu {
    Clear-Host
    Write-Host "===== MENU =====" -ForegroundColor Cyan
    Write-Host "1 - Pesquisar arquivos"
    Write-Host "2 - Excluir arquivos encontrados"
    Write-Host "3 - Sair"
    $opcao = Read-Host "Escolha uma opção"
    return $opcao
}

function Pesquisar-Arquivos {
    $global:filesFound = @()
    foreach ($path in $paths) {
        foreach ($ext in $extensions) {
            if (Test-Path $path) {
                $files = Get-ChildItem -Path $path -Filter $ext -Recurse -ErrorAction SilentlyContinue
                if ($files) {
                    $global:filesFound += $files
                }
            } else {
                Write-Host "Caminho não encontrado: $path" -ForegroundColor Yellow
            }
        }
    }
    
    if ($filesFound.Count -eq 0) {
        Write-Host "Nenhum arquivo encontrado." -ForegroundColor Green
    } else {
        Write-Host "Arquivos encontrados:" -ForegroundColor Cyan
        $filesFound | ForEach-Object { Write-Host $_.FullName }
    }
    pause
}

function Excluir-Arquivos {
    if ($filesFound.Count -eq 0) {
        Write-Host "Nenhum arquivo para excluir. Execute a pesquisa primeiro." -ForegroundColor Yellow
    } else {
        $confirm = Read-Host "Deseja excluir todos os arquivos listados? (S/N)"
        if ($confirm -match "^[sS]") {
            foreach ($file in $filesFound) {
                Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
            }
            Write-Host "Arquivos excluídos com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "Nenhum arquivo foi excluído." -ForegroundColor Yellow
        }
    }
    pause
}

while ($true) {
    $opcao = Mostrar-Menu
    switch ($opcao) {
        "1" { Pesquisar-Arquivos }
        "2" { Excluir-Arquivos }
        "3" { exit }
        default { Write-Host "Opção inválida!" -ForegroundColor Red; pause }
    }
}
