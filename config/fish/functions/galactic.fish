function galactic --description "Open a Galactic terminal or change Star Wars themes"
    set -l command $argv[1]
    switch "$command"
        case imperial sith rakatan
            $HOME/.local/bin/hypr-galactic-terminal $command
        case theme
            $HOME/.local/bin/hypr-starwars menu
        case status
            $HOME/.local/bin/hypr-starwars status
        case holonet menu
            $HOME/.local/bin/hypr-holonet-launcher
        case '*'
            printf 'Usage: galactic imperial | sith | rakatan | theme | status | holonet\n'
    end
end
