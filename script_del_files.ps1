# Solicita execução como Administrador
$adminCheck = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Definir os caminhos remotos a serem verificados
$paths = @(
    "\\SERVIDOR\Compartilhamento\Desktop",
    "\\SERVIDOR\Compartilhamento\Documents",
    "\\SERVIDOR\Compartilhamento\Downloads",
    "\\SERVIDOR\Compartilhamento\Pictures",
    "\\SERVIDOR\Compartilhamento\Scanner"
)

# Definir as extensões dos arquivos a serem pesquisados
$extensions = @("*.doc", "*.docx", "*.odt", "*.rtf", "*.txt", "*.md", "*.wpd", "*.pdf", "*.ps", "*.xps", 
                "*.xls", "*.xlsx", "*.ods", "*.csv", "*.tsv", "*.ppt", "*.pptx", "*.odp", "*.key", "*.mdb", 
                "*.accdb", "*.sql", "*.dbf", "*.db", "*.epub", "*.mobi", "*.azw", "*.azw3", "*.fb2", "*.tex", 
                "*.bib", "*.ris", "*.ai", "*.psd", "*.indd", "*.pdfa", "*.xml", "*.json", "*.yaml", 
                "*.zip", "*.rar", "*.7z", "*.tar", "*.gz", "*.bz2", "*.xz", "*.tar.gz", "*.tar.bz2", "*.tar.xz")

# Lista para armazenar arquivos excluídos
$filesDeleted = @()

# Percorrer cada caminho e excluir os arquivos automaticamente
foreach ($path in $paths) {
    foreach ($ext in $extensions) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Filter $ext -Recurse -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
                $filesDeleted += $file.FullName
            }
        } else {
            Write-Host "Caminho não encontrado: $path" -ForegroundColor Yellow
        }
    }
}

# Exibir os arquivos que foram excluídos
if ($filesDeleted.Count -eq 0) {
    Write-Host "Nenhum arquivo encontrado para exclusão." -ForegroundColor Green
} else {
    Write-Host "Arquivos excluídos:" -ForegroundColor Red
    $filesDeleted | ForEach-Object { Write-Host $_ }
}

pause
