#New-Item -ItemType HardLink -Path "$HOME\.ideavimrc" -Target "c:\projects\apps\config\rider\.ideavimrc"
#New-Item -ItemType HardLink -Path "$HOME\ohmyposh.json" -Target "c:\projects\apps\config\ohmyposh\ohmyposh.json"

New-Item -ItemType HardLink -Path "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Target "c:\projects\apps\config\wt\settings.json"
New-Item -ItemType HardLink -Path "$HOME\.glaze-wm\config.yaml" -Target "c:\projects\apps\config\glazewm\config.yaml"
