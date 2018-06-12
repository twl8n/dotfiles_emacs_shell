
Overview
--------

See the extensive comments inline.

The file .emacs is a single config file works with both Apple Mac OS X and Linux. Unknown how it behaves on MS Windows.

Unfortunately, to get multiplatform behavior, it kind of breaks with the typical convention of a single
custom-set-variables and custom-set-faces. If you find the need to save something from Emacs customization
user interface , a new custom-set-variables will appear at the end of the .emacs. You need to manually copy
any new stuff from the section at the end into blocks of code `custom-set-variables` or `custom-set-faces`.
After that, delete the spurious custom-set-variables at the end of the file.

Setting the background to nil works in both windowing and -nw emacs. Sadly, in most xterms with -nw
:background "White" ends up as gray. If you want to use Emacs in xterm, you probably want xterm-256color.

Add this to your .bashrc or .zshrc:

```
# Use 256 colors for emacs -nw white.
export TERM=xterm-256color
```

Several of the delete keys that I kept hitting by accident have been unmapped.

As far as I know, the key bindings work on Mac and Linux, in windowing and -nw modes (with xterm). It took a
lot of work to get all that working.



#### Description of files

Standard Emacs keys bindings can be strange. Everyone I know modifies the keys to some extent. The standard
key bindings are in the file default_emacs_bindings.txt or you can see them at any time in Emacs `M-x
describe-bindings`.

.emacs My dot emacs file

.emacs_minimal A minimal .emacs with (very few?) no modified key bindings. Quite a few sensible settings have been modified. You might want to use this instead of my heavily modified .emacs. To use this as your .emacs simply copy this file to your home directory as .emacs.

.emacs_alt_bindings All of the key bindings from my .emacs. Copy these into your personal .emacs as you see fit. 


#### Tramp

I use tramp heavily, and so autosaves have been disabled. When I was using them, I moved autosaves to the local machine. 
Things which slow tramp down have been disabled, and I don't miss them. There are comments.

With a slow connection you may find that ssh compressions speeds file saving in tramp. In your .ssh/config Host section:

```
Compression yes
```

I added a bit of code so that if a .emacs.desktop file exist in the current directory, it will be
used. Otherwise, desktop saving is disabled. An empty .emacs.desktop is sufficient, and must be created before
starting emacs.

My key bindings are done in the user-minor-mode-map so that they will override bindings in most (all?) modes,
and I added a hook so they would work in the minibuffer. One set of key bindings for all modes, with extra
bindings where they don't overlap with one of my preferred bindings.



#### Tramp message invalid-function (["scp"...

In some situations (?) tramp creates a file that contains meta data about connection types. Unclear how, but mine had a section for scp and that section was wrong in some way. The fix is to delete ~/.emacs.d/lisp/tramp. It will be auto-created if necessary.

In my case, the error occured when Emacs was reading my .emacs.desktop and attempting to re-open files from a previous session.

```
~/.emacs.d/lisp/tramp
```
In the emacs \*Messages\* buffer you'll see something like ```(invalid-function (["scp" nil "pp" nil]```

In the .emacs.desktop was a lisp statement:
```
(desktop-create-buffer 206
  nil
  "ubuntu"
  'dired-mode
  '(user-minor-mode)
  169
  '(nil nil)
  t
  '("/scpx:myremotehost:/home/zeus/")
  nil)
```

Copying that line and pasting into the \*scratch\* buffer (which defaults to lisp-interaction-mode) and running it (via C-j) threw up an error in the lisp debugger. The first line was:

```
Debugger entered--Lisp error: (invalid-function (["scp" nil "pp" nil] ("uname" "Linux 2.6.32-41-generic") ("test" "test") ("remote-path" ("/bin" "/usr/bin" "/usr/sbin" "/usr/local/bin")) ("remote-shell" "/bin/sh") ("readlink" "\\readlink") ("stat" "\\stat") ("file-exists" "test -e") ("id" "/usr/bin/id") ("gid-integer" 2014) ("local-encoding" base64-encode-region) ("local-decoding" base64-decode-region) ("remote-encoding" "base64") ("remote-decoding" "base64 -d") ("perl-file-spec" t) ("perl-cwd-realpath" t) ("perl" "\\perl") ("ls" "/bin/ls --color=never") ("ls-dired" t) ("uid-integer" 2014)))
```

#### Other notes

After installing Brew, one of the zsh directories has group write privileges which is ostensibly a security issue. Fix it by a recursive chmod to 755, thus removing group write. As the message suggests, you can run compaudit to get a list of the (2) insecure directories.

http://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories 

The message:

```
zsh compinit: insecure directories, run compaudit for list.
Ignore insecure directories and continue [y] or abort compinit [n]?
```
Open Terminal, and run this command:

```
sudo chmod -R 755 /usr/local/share/zsh
```

