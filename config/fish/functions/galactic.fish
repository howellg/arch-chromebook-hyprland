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
            set -l config_root "$HOME/.config/fastfetch"
            set -l logo
            set -l accent red
            switch "$STARWARS_TERMINAL_PROFILE"
                case imperial
                    set logo imperial-death-star.txt
                case sith
                    set logo sith-holocron.txt
                case rakatan
                    set logo rakatan-star-forge.txt
                    set accent cyan
            end
            if test -n "$logo"; and test -r "$config_root/imperial.jsonc"; and test -r "$config_root/$logo"
                fastfetch --config "$config_root/imperial.jsonc" \
                    --logo "$config_root/$logo" --logo-type file \
                    --logo-color-1 bright_white --logo-color-2 $accent \
                    --logo-position auto --logo-padding-right 4
            else
                fastfetch
            end
        case compact
            $HOME/.local/bin/hypr-galactic-greeting
        case help '*'
            printf '%s\n' 'GALACTIC TERMINAL'                 '  galactic here       Open terminal matching current workspace'                 '  galactic sith       Open Sith Archives terminal'                 '  galactic rakatan    Open Rakatan Research terminal'                 '  galactic imperial   Open Imperial Command terminal'                 '  galactic info       Show full fastfetch hardware/system report'                 '  galactic status     Report current desktop theme'                 '  galactic theme      Select a desktop theme'                 '  galactic holonet    Open the HoloNet launcher'
    end
end
