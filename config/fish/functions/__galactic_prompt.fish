function __galactic_prompt --description 'Compact faction prompt with git, errors and virtualenv'
    set -l oldstatus $argv[1]
    set -l badge IMPERIAL
    set -l accent ed6664
    set -l dim 96a6b9
    switch $STARWARS_TERMINAL_PROFILE
        case sith
            set badge SITH
            set accent ed4257
            set dim bc93a2
        case rakatan
            set badge RAKATAN
            set accent 64d5df
            set dim 98bfc9
    end

    set_color $dim
    printf '╭─'
    set_color --bold $accent
    printf ' ◆ %s ' $badge
    set_color $dim
    printf '  '
    set_color -o normal
    printf '%s' (prompt_pwd)
    set -l branch (fish_git_prompt '%s')
    if test -n "$branch"
        set_color $dim
        printf '  ⎇ %s' (string trim -- $branch)
    end
    if set -q VIRTUAL_ENV
        set_color $dim
        printf '  ⚙ %s' (path basename "$VIRTUAL_ENV")
    end
    if test -n "$oldstatus"; and test "$oldstatus" -ne 0
        set_color -o ff6775
        printf '  [EXIT %s]' $oldstatus
    end
    echo
    set_color $dim
    printf '╰─'
    set_color --bold $accent
    printf '❯ '
    set_color normal
end
