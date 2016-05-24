function suite_plug
    function setup
        stub_var conf_path (stub_dir)
        set plug_path $conf_path/plugins
        set plug_function_path $conf_path/functions
        set plug_complete_path $conf_path/completions
        set plug_config_path $conf_path/conf.d

        mkdir -p $plug_path
        mkdir -p $plug_function_path
        mkdir -p $plug_complete_path
        mkdir -p $plug_config_path

        mkdir $plug_path/test-plugin

        function git_stub
            echo git $argv
            switch $argv[1]
                case 'clone'
                    set -l parts (string split '/' $argv[2])
                    set -l plugin (string replace -r '.git$' '' $parts[-1])
                    set -l target_path "$plug_path/$plugin"

                    mkdir -p $target_path
                    mkdir $target_path/functions
                    mkdir $target_path/completions
                    mkdir $target_path/conf.d

                    touch $target_path/functions/$plugin.fish
                    touch $target_path/completions/$plugin.fish
                    touch $target_path/conf.d/$plugin.fish
            end

            return 0
        end
        stub git git_stub
    end

    function test_empty_arguments
        set output (plug)
        assert_equal 0 $status
        assert_equal (plug list) "$output"
    end

    function test_help
        set expected (plug help)

        for arg in help --help -h
            set output (plug $arg)
            assert_equal 0 $status
            assert_equal "$expected" "$output"
        end
    end

    function test_list
        set expected test-plugin

        for arg in list ls
            set output (plug $arg)
            assert_equal 0 $status
            assert_equal "$expected" "$output"
        end
    end

    function test_install_with_unknown
        set output (plug install unknown)
        assert_equal 1 $status
        assert_includes "plug: unknown repository 'unknown'" $output
        refute_includes 'unknown' (plug list)
    end

    function test_install_with_http_url
        set output (plug install http://github.com/terlar/fish-plug.git)
        assert_equal 0 $status
        assert_includes "git clone http://github.com/terlar/fish-plug.git $plug_path/fish-plug" $output
        assert_includes "plug: installed 'fish-plug'" $output

        assert_includes 'fish-plug' (plug list)

        assert (test -d $plug_path/fish-plug)
        assert (test -f $plug_function_path/fish-plug.fish)
        assert (test -f $plug_complete_path/fish-plug.fish)
        assert (test -f $plug_config_path/fish-plug.fish)
    end

    function test_install_with_https_url
        set output (plug install https://github.com/terlar/fish-plug.git)
        assert_equal 0 $status
        assert_includes "git clone https://github.com/terlar/fish-plug.git $plug_path/fish-plug" $output
        assert_includes "plug: installed 'fish-plug'" $output

        assert_includes 'fish-plug' (plug list)

        assert (test -d $plug_path/fish-plug)
        assert (test -f $plug_function_path/fish-plug.fish)
        assert (test -f $plug_complete_path/fish-plug.fish)
        assert (test -f $plug_config_path/fish-plug.fish)
    end

    function test_install_with_ssh_url
        set output (plug install git@github.com:terlar/fish-plug.git)
        assert_equal 0 $status
        assert_includes "git clone git@github.com:terlar/fish-plug.git $plug_path/fish-plug" $output
        assert_includes "plug: installed 'fish-plug'" $output

        assert_includes 'fish-plug' (plug list)

        assert (test -d $plug_path/fish-plug)
        assert (test -f $plug_function_path/fish-plug.fish)
        assert (test -f $plug_complete_path/fish-plug.fish)
        assert (test -f $plug_config_path/fish-plug.fish)
    end

    function test_install_with_github_path
        set output (plug install terlar/fish-plug)
        assert_equal 0 $status
        assert_includes "git clone https://github.com/terlar/fish-plug.git $plug_path/fish-plug" $output
        assert_includes "plug: installed 'fish-plug'" $output

        assert_includes 'fish-plug' (plug list)

        assert (test -d $plug_path/fish-plug)
        assert (test -f $plug_function_path/fish-plug.fish)
        assert (test -f $plug_complete_path/fish-plug.fish)
        assert (test -f $plug_config_path/fish-plug.fish)
    end

    function test_update
        mkdir $plug_path/other-plugin

        function git_stub
            echo $PWD
            echo git $argv
            return 0
        end
        stub git git_stub

        set output (plug update)
        assert_equal 0 $status

        assert_includes "$plug_path/test-plugin" $output
        assert_includes 'git pull' $output
        assert_includes "plug: updated 'test-plugin'" $output

        assert_includes "$plug_path/other-plugin" $output
        assert_includes 'git pull' $output
        assert_includes "plug: updated 'other-plugin'" $output
    end

    function test_update_with_plugin
        mkdir $plug_path/other-plugin

        function git_stub
            echo $PWD
            echo git $argv
            return 0
        end
        stub git git_stub

        set output (plug update test-plugin)
        assert_equal 0 $status

        assert_includes "$plug_path/test-plugin" $output
        assert_includes 'git pull' $output
        assert_includes "plug: updated 'test-plugin'" $output

        refute_includes "$plug_path/other-plugin" $output
        refute_includes "plug: updated 'other-plugin'" $output
    end

    function test_remove
        set output (plug install terlar/fish-plug)
        assert (test -d $plug_path/fish-plug)
        assert (test -f $plug_function_path/fish-plug.fish)
        assert (test -f $plug_complete_path/fish-plug.fish)
        assert (test -f $plug_config_path/fish-plug.fish)

        assert_includes 'fish-plug' (plug list)

        set output (plug remove fish-plug)

        refute_includes 'fish-plug' (plug list)

        refute (test -d $plug_path/fish-plug)
        refute (test -f $plug_function_path/fish-plug.fish)
        refute (test -f $plug_complete_path/fish-plug.fish)
        refute (test -f $plug_config_path/fish-plug.fish)
    end
end

source (dirname (status -f))/helper.fish
