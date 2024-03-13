{ lib, config, ... }:

let
  mapAttrsAndKeys = callback: list:
    (lib.foldl' (acc: value: acc // (callback value)) { } list);
  cfg = config.desktop.hyprland.lock;

in {
  home-manager.users = let
    users = lib.filter (user: config.system.user.${user}.enable == true)
      (lib.attrNames config.system.user);
  in mapAttrsAndKeys (user:
    let username = config.system.user.${user}.username;
    in {
      ${username}.home.file.".config/hypr/hypridle.conf".text = ''
        general {
            lock_cmd = pidof hyprlock || hyprlock
            before_sleep_cmd = loginctl lock-session
            after_sleep_cmd = hyprctl dispatch dpms on
        }

        listener {
            timeout = ${cfg.secondsToLowerBrightness}
            on-timeout = brightnessctl -s set 10 && brightnessctl -sd rgb:kbd_backlight set 0
            on-resume = brightnessctl -r
        }

        listener {
            timeout = ${cfg.secondsToLock}
            on-timeout = swaylock-wrapper lock
        }

        listener {
            timeout = ${cfg.secondsToDisableMonitors}
            on-timeout = swaylock-wrapper off
            on-resume = hyprctl dispatch dpms on
        }

        listener {
            timeout = ${cfg.secondsToSuspend}
            on-timeout = swaylock-wrapper suspend
        }
      '';
    }) users;
}
