if (-not (Test-Path -Path "lib" -PathType Container)) {
    New-Item -ItemType Directory -Path "lib" | Out-Null
}
Set-Location "lib"
git clone https://github.com/kikito/anim8
git clone https://github.com/vrld/hump
Set-Location "../"