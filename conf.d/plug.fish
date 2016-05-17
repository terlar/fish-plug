# Set defaults
if not set -q plug_path
    if not set -q fish_config_path
        # Set config path
        set -l config_home ~/.config
        if set -q XDG_CONFIG_HOME
            set config_home $XDG_CONFIG_HOME
        end
        set -g fish_config_path "$config_home/fish"
    end

    # Set plug path
    set -U plug_path "$fish_config_path/plug"
end

set -q plug_function_path
or set -U plug_function_path "$fish_config_path/functions"

set -q plug_complete_path
or set -U plug_complete_path "$fish_config_path/completions"

set -q plug_config_path
or set -U plug_config_path "$fish_config_path/conf.d"

# Create missing directories
test -d $plug_path
or mkdir -p $plug_path

test -d $plug_function_path
or mkdir -p $plug_function_path

test -d $plug_complete_path
or mkdir -p $plug_complete_path

test -d $plug_config_path
or mkdir -p $plug_config_path
