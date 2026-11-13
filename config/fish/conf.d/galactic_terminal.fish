# Galactic appearance in Kitty. Explicit Sith/Rakatan launchers take priority.
# The ordinary 'kitty' command inherits the selected global Star Wars scheme.
# Non-Kitty Fish, SSH and Catppuccin retain their existing prompt/greeting.
if status is-interactive; and set -q KITTY_WINDOW_ID; and not set -q STARWARS_TERMINAL_PROFILE
    set -l theme_file $HOME/.local/state/starwars-theme/selection
    if test -f $theme_file
        set -l choice (string trim -- (cat $theme_file))
        switch $choice
            case imperial sith rakatan
                set -gx STARWARS_TERMINAL_PROFILE $choice
        end
    end
end
if status is-interactive; and set -q STARWARS_TERMINAL_PROFILE
    function fish_greeting --description 'Compact Galactic systems check'
        $HOME/.local/bin/hypr-galactic-greeting
    end
    function fish_prompt --description 'Galactic two-line command prompt'
        set -l oldstatus $status
        __galactic_prompt $oldstatus
    end
    function fish_right_prompt --description 'Subtle Galactic local clock'
        set_color 738598
        date '+%H:%M'
        set_color normal
    end
    # Syntax colors are scoped to this terminal only.
    switch $STARWARS_TERMINAL_PROFILE
        case sith
            set -g fish_color_command ed607b
            set -g fish_color_param e9c2cc
            set -g fish_color_quote e7b06e
            set -g fish_color_cwd d46f88
        case rakatan
            set -g fish_color_command 64d5df
            set -g fish_color_param b9dfe7
            set -g fish_color_quote d5ad67
            set -g fish_color_cwd 68cad1
        case imperial
            set -g fish_color_command ed8883
            set -g fish_color_param c7d2de
            set -g fish_color_quote d8b170
            set -g fish_color_cwd ed6664
    end
end
