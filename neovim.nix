{ pkgs, ... }:
(
  pkgs.neovim.override {
    configure = {
      customRC = (builtins.readFile ./init.vim) + ''
        let g:racer_cmd = "${pkgs.rustracer}/bin/racer"
        let g:racer_experimental_completer = 1
      '';
      vam.pluginDictionaries = [
        {
          names = [
            "airline"
            "vim-airline-themes"
            "neomake"
            "fugitive"
            "Supertab"
            "The_NERD_tree"
            "deoplete-nvim"
            "jellybeans"
            "vim-nix"
            "rust-vim"
          ];
        }
        {
          name = "deoplete-jedi";
          ft_regex = "python";
        }
        {
          name = "vim-racer";
          filename_regex = ''\(.*\.rs\|Cargo\.\(toml\|lock\)\)'' + "$";
        }
      ];
      vam.knownPlugins = pkgs.vimPlugins // (with pkgs.vimUtils; {
        jellybeans = buildVimPluginFrom2Nix {
          name = "jellybeans-2016-10-18";
          src = pkgs.fetchFromGitHub {
            owner = "nanotech";
            repo = "jellybeans.vim";
            rev = "fd089ca8a242263f61ae7bddce55a007d535bc65";
            sha256 = "00knmhmfw9d04p076cy0k5hglk7ly36biai8p9b6l9762irhzypp";
          };
          dependencies = [];
        };

        vim-racer = buildVimPluginFrom2Nix {
          name = "vim-racer-2017-05-08";
          src = pkgs.fetchgit {
            url = "https://github.com/racer-rust/vim-racer";
            rev = "34b7f2a261f1a7147cd87aff564acb17d0172c02";
            sha256 = "13xcbw7mw3y4jwrjszjyvil9fdhqisf8awah4cx0zs8narlajzqm";
          };
          dependencies = [];

        };
      });
    };
  }
)
