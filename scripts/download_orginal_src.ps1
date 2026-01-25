#Drücken Sie die Windows-Taste, suchen Sie nach „PowerShell“ und wählen Sie Als Administrator #ausführen.
#Geben Sie den folgenden Befehl ein, um die Ausführung für lokale Skripte freizuschalten:
#Set-ExecutionPolicy RemoteSigned
#Bestätigen Sie die Abfrage mit A (Ja, alle). 




# Ziel-URL und lokales Verzeichnis
$baseUrl = "http://oe5dxl.hamspirit.at:8025"
$folderPath = "/aprs/c/"
$fullUrl = $baseUrl + $folderPath
$outputDir = "C:\Users\oe3jt\dxlaprs\downloads"

if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir }

# Webseite abrufen
$response = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing

# Links filtern und Download-URL korrekt zusammenbauen
$links = $response.Links | Where-Object { $_.href -notmatch "/$|\?" }

foreach ($link in $links) {
    # Extrahiere nur den reinen Dateinamen (entfernt Pfade wie /aprs/c/)
    $fileName = Split-Path $link.href -Leaf
    $downloadUrl = "$fullUrl$fileName"
    $targetPath = Join-Path $outputDir $fileName
    
    try {
        Write-Host "Lade herunter: $downloadUrl" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $downloadUrl -OutFile $targetPath -ErrorAction Stop
    } catch {
        Write-Host "Fehler bei $fileName : $($_.Exception.Message)" -ForegroundColor Red
    }
}
