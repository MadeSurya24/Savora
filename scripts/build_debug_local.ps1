$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
$env:GRADLE_USER_HOME = Join-Path $root ".gradle-user-home"

Set-Location $root
flutter build apk --debug --no-pub
