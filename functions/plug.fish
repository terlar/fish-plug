function plug -a cmd --description 'Plugin manager for fish'
    set -l ver '0.1.0'

    set -e argv[1]
    test -z $cmd
    and set cmd list

    function plug:help
        echo 'Usage: plug COMMAND [ARGS]...'
        echo
        echo 'Options:'
        echo '  -h, --help  Display the help message'
        echo
        echo 'Commands:'
        echo '  list                    List installed plugins'
        echo '  update [<plugin>]       Update installed plugins'
        echo '  install <plugin>|<url>  Install plugin'
        echo '  remove <plugin>         Remove installed plugin'
        echo '  help                    Display the help message'
        echo '  ls                      List installed plugins'
        echo '  rm <plugin>             Remove installed plugin'
    end

    function plug:list
        for i in $plug_path/*
            string replace $plug_path/ '' "$i"
        end
    end

    function plug:update -a plugin
        if test -z $plugin
            for i in $plug_path/*
                set -l plugin (string replace $plug_path/ '' "$i")
                pushd "$i"
                git pull
                popd
                echo "plug: updated '$plugin'"
            end
        else
            if test -d "$plug_path/$plugin"
                pushd "$plug_path/$plugin"
                git pull
                popd
                echo "plug: updated '$plugin'"
            else
                echo "plug: unknown plugin '$plugin'"
                return 1
            end
        end

        return 0
    end

    function plug:install -a repo
        set -l parts (string split '/' $repo)
        set -l plugin (string replace -r '.git$' '' $parts[-1])
        set -l target_path "$plug_path/$plugin"

        if test -d "$target_path"
            return
        end

        switch $repo
            case 'http://*' 'https://*' '*@*:*.git'
                git clone "$repo" "$target_path"
            case '*/*'
                git clone "https://github.com/$repo.git" "$target_path"
            case '*'
                echo "plug: unknown repository '$plugin'"
                return 1
        end

        for i in "$target_path/functions"/*.fish
            ln -s $i "$plug_function_path"/.
        end

        for i in "$target_path/completions"/*.fish
            ln -s $i "$plug_complete_path"/.
        end

        for i in "$target_path/init.d"/*.fish
            ln -s $i "$plug_config_path"/.
        end

        echo "plug: installed '$plugin'"
    end

    function plug:remove -a plugin
        set -l target_path "$plug_path/$plugin"

        if not test -d "$target_path"
            echo "plug: unknown plugin '$plugin'"
            return 1
        end

        rm -rf "$target_path"
        find -L "$plug_function_path" -type l -delete
        find -L "$plug_complete_path" -type l -delete
        find -L "$plug_config_path" -type l -delete

        echo "plug: removed '$plugin'"
        return 0
    end

    switch $cmd
        case '-v' '--version' 'version'
            echo $ver
        case '-h' '--help'
            plug:help $argv
        case 'ls'
            plug:list $argv
        case 'rm'
            plug:remove $argv
        case 'install'
            plug:install $argv
        case '*/*' 'http://*' 'https://*' '*@*:*.git'
            plug:install $cmd
        case '*'
            if functions -q "plug:$cmd"
                eval "plug:$cmd" $argv
            else
                plug:help
                return 1
            end
    end
end

