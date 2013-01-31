
Overview
--------

See the extensive comments inline.

.emacs.macos has the custom-set-faces for Macos fonts. 

Setting the background to nil works in both windowing and -nw emacs. Sadly, in most xterms with -nw
:background "White" ends up as gray.

forward-screen and backward-screen are not working properly.

Several of the delete keys that I kept hitting by accident have been unmapped.

As far as I know, the key bindings work on Mac and Linux, in windowing and -nw modes (with xterm). It took a
lot of work to get all that working.

I use tramp heavily, and so autosaves have been moved to the local machine, and most of the autosaving is
disabled. Things which slow tramp down have been disabled, and I don't miss them. There are comments.

I added a bit of code so that if a .emacs.desktop file exist in the current directory, it will be
used. Otherwise, desktop saving is disabled. An empty .emacs.desktop is sufficient, and must be created before
starting emacs.

My key bindings are done in the user-minor-mode-map so that they will override bindings in most (all?) modes,
and I added a hook so they would work in the minibuffer. One set of key bindings for all modes, with extra
bindings where they don't overlap with one of my preferred bindings.


