$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
$env:GRADLE_USER_HOME = Join-Path $root ".gradle-user-home"
$env:JAVA_TOOL_OPTIONS = "-Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true -Djava.net.useSystemProxies=false"

Set-Location $root
flutter run -d emulator-5554 --no-pub
