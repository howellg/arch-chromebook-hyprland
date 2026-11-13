function galactic --description "Star Wars terminal profiles and system information"
    set -l command $argv[1]
    switch "$command"
        case imperial sith rakatan
            $HOME/.local/bin/hypr-galactic-terminal $command
        case here auto
            $HOME/.local/bin/hypr-galactic-terminal auto
        case theme
            $HOME/.local/bin/hypr-starwars menu
        case status
            $HOME/.local/bin/hypr-starwars status
        case holonet menu
            $HOME/.local/bin/hypr-holonet-launcher
        case info fetch
            fastfetch
        case compact
            $HOME/.local/bin/hypr-galactic-greeting
        case help '*'
            printf '%s\n' 'GALACTIC TERMINAL'                 '  galactic here       Open terminal matching current workspace'                 '  galactic sith       Open Sith Archives terminal'                 '  galactic rakatan    Open Rakatan Research terminal'                 '  galactic imperial   Open Imperial Command terminal'                 '  galactic info       Show full fastfetch hardware/system report'                 '  galactic status     Report current desktop theme'                 '  galactic theme      Select a desktop theme'                 '  galactic holonet    Open the HoloNet launcher'
    end
end
