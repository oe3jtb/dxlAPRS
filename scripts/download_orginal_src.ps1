#Drücken Sie die Windows-Taste, suchen Sie nach „PowerShell“ und wählen Sie Als Administrator #ausführen.
#Geben Sie den folgenden Befehl ein, um die Ausführung für lokale Skripte freizuschalten:
#Set-ExecutionPolicy RemoteSigned
#Bestätigen Sie die Abfrage mit A (Ja, alle). 

$baseUrl = "http://oe5dxl.hamspirit.at:8025"
$folderPath = "/aprs/c/"
$fullUrl = $baseUrl + $folderPath
$outputDir = "C:\Users\oe3jt\dxlaprs\downloads"

if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir }

$response = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing
$links = $response.Links | Where-Object { $_.href -notmatch "/$|\?" }

foreach ($link in $links) {
    $fileName = Split-Path $link.href -Leaf
    $downloadUrl = "$fullUrl$fileName"
    $targetPath = Join-Path $outputDir $fileName
    
    try {
        Write-Host "Lade herunter: $downloadUrl" -ForegroundColor Cyan
        
        # 1. Datei herunterladen
        $webRequest = Invoke-WebRequest -Uri $downloadUrl -OutFile $targetPath -PassThru -ErrorAction Stop
        
        # 2. Zeitstempel vom Server abfragen (Last-Modified Header)
        $serverDate = $webRequest.Headers["Last-Modified"]
        
        if ($serverDate) {
            # 3. Das lokale Datum der Datei anpassen
            (Get-Item $targetPath).LastWriteTime = [DateTime]::Parse($serverDate)
            Write-Host "Zeitstempel gesetzt: $serverDate" -ForegroundColor Green
        }
    } catch {
        Write-Host "Fehler bei $fileName : $($_.Exception.Message)" -ForegroundColor Red
    }
}