function __fish_plug_needs_command
    set cmd (commandline -opc)
    if [ (count $cmd) -eq 1 ]
        return 0
    else
        set -l skip_next 1
        # Skip first word because it's "plug" or a wrapper
        for c in $cmd[2..-1]
            test $skip_next -eq 0
            and set skip_next 1
            and continue
            switch $c
                case "--help"
                    continue
                case "--version"
                    return 1
                case "*"
                    echo $c
                    return 1
            end
        end
        return 0
    end
    return 1
end

function __fish_plug_using_command
    set -l cmd (__fish_plug_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd $argv
    and return 0

    return 1
end

function __plug_commands
    plug help | string match -r '^\s{2}[^-]+.*' | string replace -r '^\s+(\w+)\s([<\[].*[\]>]\s)*\s+(.*)' '$1\t$3'
end

complete -f -c plug -n '__fish_plug_needs_command' -a '(__plug_commands)'
complete -f -c plug -n '__fish_plug_using_command rm' -a '(plug ls)' -d 'Plugin'
complete -f -c plug -n '__fish_plug_using_command remove' -a '(plug ls)' -d 'Plugin'
complete -f -c plug -n '__fish_plug_using_command update' -a '(plug ls)' -d 'Plugin'

complete -f -c plug -n '__fish_plug_needs_command' -l 'version' -s 'v' -d 'Display the version'
complete -f -c plug -n '__fish_plug_needs_command' -l 'help' -s 'h' -d 'Display the help message'
