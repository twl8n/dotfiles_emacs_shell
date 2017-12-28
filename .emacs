1
;; Tom Laudeman's .emacs file.

;; Download from
;; http://github.com/twl8n/dotfiles_emacs_shell/.emacs

;; Note that I've moved custom settings inside an if that tests for operating system and type of windowing or
;; cli environment. Also, font names aren't portable across platforms.  And other stuff.

;; Skip to "Core key bindings below" for key bindings.

;; overload set-file-acl which doesn't work. 
(defun set-file-acl (file acl-str) t)

;; http://stackoverflow.com/questions/24779041/disable-warning-about-emacs-d-in-load-path

;; Use ~/.emacs.d/lisp, which works fine with Linux and OSX. If variable load-path does not contain your home
;; directory .emacs.d after using ~/, then you must manually add explicit paths. The lisp subdirectory was
;; created to prevent accidental name conflicts.  Having a valid load-path is necessary to make auto-complete
;; work, and probably necessary for other stuff too. Note that there are other references to ~/ below. Best to
;; figure out how to make ~/ work.

(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "/Users/twl/.emacs.d/lisp")

;; What does this message hook do?
(add-hook 'message-mode-hook 'turn-on-orgtbl)

;; For some strange reason, M-x can't run turn-on-orgtbl which also means that it won't tab-complete.
;; (You can run it with M-: eval-expression (turn-on-orgtbl) but who can remember that?)
;; I've created a little interactive function to handle this, and being interactive the name wil tab-complete.
;; You only need to remember M-x orgtbl tab
;; Yes, I know that the args are ignored, but I can't be bothered to think about that now.

(defun orgtbl-enable (xx yy)
  "Turn on the orgtbl-mode."
  (interactive "*r")
  (turn-on-orgtbl))

;; (add-to-list 'load-path "/home/mst3k/.emacs.d")
;; (add-to-list 'load-path "/home/merry.terry/.emacs.d")
;; (add-to-list 'load-path "/Users/mst/.emacs.d")
;; (add-to-list 'load-path "/Users/mst3k/.emacs.d")

;; Assume Emacs >= 24
;; M-x list-packages to list and install.
;; https://www.emacswiki.org/emacs/InstallingPackages

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))


;; Notes about color.
;; list-colors-display

;; (tty-color-alist)

;; (("black" 0 0 0 0) ("red" 1 52685 0 0) ("green" 2 0 52685 0) ("yellow" 3 52685 52685 0) ("blue" 4 0 0 61166) ("magenta" 5 52685 0 52685) ("cyan" 6 0 52685 52685) ("white" 7 58853 58853 58853))

;; When set-background-color has no effect, use custom-set-faces to change the :background color of the
;; default theme. When white is #e5e5e5 aka 58853, then set the background to nil in order to get white. The
;; default theme is apparently "user", but I have not seen any commands using the name "user".

;; (custom-set-faces '(default ((t (:background nil)))))
;; (face-attribute 'default :background )
;; "unspecified-bg" *************************************************

;; This works and seems to be the same as custom-set-faces :background nil. 
;; (set-face-attribute 'default nil :background "unspecified-bg")

;; This also works. custom-set-faces :background will accept nil or "unspecified-bg" as args.
;; (custom-set-faces '(default ((t (:background "unspecified-bg")))))

;; This works in nw to set the background white.
;; (set-face-background 'default "unspecified-bg")

;; Sets a tty color to white to #fffff, but this is not the "white" used by custom-set-faces. The default
;; white in nw (nonwindowing mode) is #e5e5e5, although changing this doesn't seem to fix anything. After
;; "fixing" white, custom-set-faces and set-face-background still make a #e5e5e5 background when asked to use
;; "white"

;; (tty-color-define "white" 7 (list (* 257 #xff) (* 257 #xff) (* 257 #xff)))

;; This does not work in nw, but it is unclear why. It is clear that any valid color universally turns the
;; background to #e5e5e5.

;; (set-face-attribute 'default nil :background "#ffffff")

;; This is a 'require' that knows how to handle missing packages
;; gracefully. Return t on success and nil on failure so we can test the return
;; value.

(defun safe-require (package_name)
  (condition-case err
      ((lambda ()
	 (require package_name)
	 (message "safe-require ok: %s" package_name)
	 t ))
    (error
     (message "safe-require warning: %s" (error-message-string err))
     nil )))

;; None of this package stuff works due to multiple requirements. Maybe it isn't too hard, but I gave up on
;; the second error. There are no docs for installing use-package, and no package for it in Melpa. Instead,
;; just add this one line to enable flycheck, which was the whole point of use-package.

;; For some reason, loading this causes a long delay during load, perhaps because fly-check is checking the
;; .emacs file or checking every open file (which could be a large number of filess when using
;; .emacs.desktop)? In any case, Emacs appears to be locked up. Not so much a feature, so fly-check-mode is
;; not enabled.

;; (add-hook 'after-init-hook 'global-flycheck-mode)

;; http://emacs.stackexchange.com/questions/5828/why-do-i-have-to-add-each-package-to-load-path-or-problem-with-require-packag 
;; (package-initialize)
;; (use-package flycheck
;;   :ensure t
;;   :init (global-flycheck-mode))

;; Hmmm. This doesn't use safe-require, so I wonder what happens if we dont' have sql-indent.el?
(eval-after-load "sql"
  '(load-library "sql-indent"))

;; You must enable current line highlighting mode before setting the face. Set the highlight line mode color
;; to very light gray. hl-line-mode only works on a per-buffer basis. The docs say the color is set via
;; hl-line, but some other web page said hl-line-face, which works in Emacs v24. keywords hi hilite current
;; line cursor hilight
(global-hl-line-mode)
(set-face-background hl-line-face "#eeeeee")

;; Arg omitted, positive, or nil enables. Zero disables. Also see show-paren-delay
(show-paren-mode)

(setq debug-on-error nil)

;; Change isearch to always treat a single space literally, and not glob multiple spaces.
;; One person suggests using quoted space in isearch when lax whitespace is enabled.
;; Related:
;; variable search-whitespace-regexp normally "\\s-+"
;; function isearch-toggle-lax-whitespace

;; vars
(setq isearch-lax-whitespace nil)
(setq isearch-regexp-lax-whitespace nil)

;; Change isearch to always leave the mark at the beginning.
;; https://www.emacswiki.org/emacs/IncrementalSearch

(add-hook 'isearch-mode-end-hook 'my-goto-match-beginning)
(defun my-goto-match-beginning ()
  (when (and isearch-forward isearch-other-end)
    (goto-char isearch-other-end)))

(defadvice isearch-exit (after my-goto-match-beginning activate)
  "Go to beginning of match."
  (when (and isearch-forward isearch-other-end)
    (goto-char isearch-other-end)))


;; Force isearch to be case insensitive. Normally it is, but in find-dired is oddly becomes case-sensitive
;; which is irritating when it is case-insensitive everywhere else.
(setq isearch-case-fold-search t)

(setq standard-indent 4)
(setq nxml-child-indent standard-indent)

;; cperl-mode is preferred to perl-mode, but only if you fix the cperl default
;; settings.  One of the best features of cperl-mode is that indent does not get
;; confused by regular expressions. Normal perl-mode thinks $) in a regex is a
;; variable, not end-of-line closing capture. I've seen # in a regex confuse perl-mode indentation.
(defalias 'perl-mode 'cperl-mode)

; Start blocks on a new line, just like perl-mode. Default is nil.
(setq cperl-extra-newline-before-brace t)

; Prevent left brace from being indented, just like perl-mode. aka amount of
; extra indent for left brace. Default is 2.
(setq cperl-continued-statement-offset 0)

; Proper indent for everything execpt left brace, just like perl-mode. Default
; is nil.
(setq cperl-indent-wrt-brace t)

; The indent level. Default is 2.
(setq cperl-indent-level standard-indent)

;; Do not change } else to } \n else.
;; *Non-nil means that BLOCK-end `}' followed by else/elsif/continue
;; may be merged to be on the same line when indenting a region.
(setq cperl-merge-trailing-else nil)

;; These settings either didn't do anything, or did things I don't like.


;; (setq cperl-invalid-face nil)
;; (setq cperl-indent-parens-as-block t)
;; (setq cperl-electric-lbrace-space nil)
;; (setq cperl-auto-newline nil) ;; this one is really irritating


(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.md" . markdown-mode) auto-mode-alist))


;;http://code.google.com/p/js2-mode/wiki/InstallationInstructions

(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(autoload 'php-mode "php-mode.el" nil t)
;; somehow nxhtml overrides the php setting. Investigate.
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))


;; http://stackoverflow.com/questions/7228529/double-indent-when-using-emacs-php-mode
;; http://www.emacswiki.org/emacs/IndentingC#toc2
;; Align { } with opening statement, aka "linux" style.
;;    if(foo)
;;    {
;;        bar++;
;;    }

(add-hook 'php-mode-hook 'my-php-mode-hook)
(defun my-php-mode-hook ()
  "My PHP mode configuration."
  (setq indent-tabs-mode nil
        tab-width 4
        c-basic-offset 4
        c-default-style "linux"
        comment-multi-line nil
        comment-start "/*"
        comment-end   "*/"
        comment-style 'extra-line))

;; The hook settings below enable // comments for php.

;; (defun my-php-mode-hook ()
;;   "My PHP mode configuration."
;;   (setq indent-tabs-mode nil
;;         tab-width 4
;;         c-basic-offset 4
;;         c-default-style "linux"
;;         comment-start "//"
;;         comment-end   ""
;;         comment-style 'indent-or-triple))


(setq auto-mode-alist (cons (cons "\\.java$" 'c-mode) auto-mode-alist))
;; (setq auto-mode-alist (cons (cons "\\.java$" 'java-mode) auto-mode-alist))
;; (setq auto-mode-alist (cons (cons "\\.cgi$" 'perl-mode) auto-mode-alist))
(setq auto-mode-alist (cons (cons "\\.cgi$" 'cperl-mode) auto-mode-alist))

;; Added nov 24 2016
;; http://clojure-doc.org/articles/tutorials/emacs.html
;; Add melpa so we can get clojure related stuff.
;; https://github.com/clojure-emacs/clojure-mode
;; https://github.com/clojure-emacs/cider
;; https://github.com/bbatsov/projectile

;; Manually install cider
;; M-x package-install [RET] cider [RET]
;; Manually refresh the package contents
;; M-x package-refresh-contents [RET]

(require 'package)

;; This should (auto?) install cider.
;; (unless (package-installed-p 'cider)
;;   (package-install 'cider))
;; (add-to-list 'package-pinned-packages '(cider . "melpa-stable") t)

(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(package-initialize)


;; added jun 24 2015
;; https://github.com/mblakele/xquery-mode
;; xquery mode
;; (require 'xquery-mode)
;; (autoload 'xquery-mode "xquery-mode" "XQuery mode" t )
;; (setq auto-mode-alist
;;       (append '(("\\.xqy$" . xquery-mode)) auto-mode-alist))


;; http://stackoverflow.com/questions/2081577/setting-emacs-split-to-horizontal Stop the
;; window from splitting vertically. For example, when compiling, I want the window split
;; horizontally with code on top and compile results on the bottom.

(setq split-height-threshold 0)
(setq split-width-threshold 0)

;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Just-Spaces.html#Just-Spaces
;; M-x tabify scans the region for sequences of spaces, and converts sequences of at least
;; two spaces to tabs if that can be done without changing indentation. M-x untabify
;; changes all tabs in the region to appropriate numbers of spaces.

(setq-default indent-tabs-mode nil)

;; Simply setting fill-column is not quite powerful enough, so use
;; setq-default. Might be necessary to set it in the hook for various
;; modes. Also might try kill-local-variable in the hook.
;; http://stackoverflow.com/questions/5373703/emacs-set-fill-column-in-change-log-mode

;; (defun my-change-log-mode-hook ()
;;   (setq fill-column 120))
;; (add-hook 'change-log-mode-hook 'my-change-log-mode-hook)

; If 120 is too long, and 80 seems too short then try 100.

(setq-default fill-column 110)

;; desktop-files-not-to-save defaults to "\\(^/[^/:]*:\\|(ftp)$\\)" but that breaks tramp
;; saving tramp dired (and tramp files?).  Basically, I want to save everything. This
;; could slow down startup when there is a large .emacs.desktop, leaving it up to the user
;; to clean up at the end of a session, before quitting.

(setq desktop-files-not-to-save "^$")

;; Two settings to speed up tramp. tramp-verbose defaults to 3. Only set it higher for
;; debugging.

(setq tramp-verbose 0)

;; As far as I know, I don't want emacs doing anything with version control. I certaily
;; don't want tramp running extra commands to check on the version control status of
;; files.

(setq vc-ignore-dir-regexp
      (format "\\(%s\\)\\|\\(%s\\)"
              vc-ignore-dir-regexp
              tramp-file-name-regexp))

;; Tramp maintains its own control master, so even when tramp is using ControlMaster, you won't find the
;; normal file in ~/.ssh/. The default tramp-ssh-controlmaster-options is "-o ControlMaster=auto -o
;; ControlPath='tramp.%%C' -o ControlPersist=no" but heaven only knows what is the root path. I wasn't able to
;; find it. I've changed the path to something I can find, and put the tramp file in .ssh (with a tramp-ish
;; name) where ssh keeps its ControlPath

;; See "tramp does not use default ssh ControlPath" at:
;; https://www.gnu.org/software/emacs/manual/html_node/tramp/Frequently-Asked-Questions.html

;; The older information here is interesting, but clearly incomplete: http://david.woodhou.se/openssh-control.html 

(setq tramp-ssh-controlmaster-options
                (concat
                  "-o ControlPath=~/.ssh/tramp-%%r@%%h:%%p "
                  "-o ControlMaster=yes -o ControlPersist=yes"))

;; Using the tramp/ssh protocol scpx seems faster than scp. (scpc is obsolete, and apparently no longer
;; supported.) Check by using describe-variable on tramp-default-method (assuming that you haven't already
;; changed it, as I have below). For a one-time test of scpx, or scp, you can also open a remote dir using an
;; explicit protocol as such as: /scpx:remote_host:remote_dir/ and any files opened in that dir will be opened
;; with the same method as the directory.

;; http://lists.gnu.org/archive/html/tramp-devel/2012-03/msg00013.html
;; http://www.gnu.org/software/tramp/

(setq tramp-default-method "scpx")

;; Disable auto save for all buffers. I manually disable auto-save when I'm using tramp or
;; sshfs and fuse. Might be better to just eval this by hand rather than have it
;; here. However, I'm typically a compusive saver so I probably won't notice if it
;; disabled.  http://www.emacswiki.org/emacs/AutoSave

(setq auto-save-default nil)

;; Really, totally disable backups.
(setq make-backup-files nil)

;; Do not backup or auto save sensitive or encrypted files. Elisp regex syntax is icky. This appends to the
;; same list that associates file extensions with programming language modes like cperl-mode, c-mode,
;; etc. More below.
;; http://stackoverflow.com/questions/151945/how-do-i-control-how-emacs-makes-backup-files

(setq auto-mode-alist
      (append
       (list
        '("\\.\\(vcf\\|gpg\\)$" . sensitive-minor-mode)
        )
       auto-mode-alist))

;; http://www.emacswiki.org/emacs/BackupDirectory 
;; http://stackoverflow.com/questions/151945/how-do-i-control-how-emacs-makes-backup-files

;; This seems to help performance with sshfs fuse file systems by changing some remote
;; operations to local. Also keeps the directory tree cleaner.

;; Nov 11 2014 Oddly, even with auto save disabled, some files occasionally end up in .saves. Unclear why, but
;; it does mean that if you want those random saves to be local, you still need to configure a local save
;; directory.

;; auto-save-file-name-transforms '((".*" "~/.saves/\\1" t))

(setq
 auto-save-file-name-transforms '((".*" ".saves/\\1" t))
 backup-by-copying-when-linked t ; this should not clobber symlinks, and seems smarter
 backup-by-copying nil      ; (old?) don't clobber symlinks
 backup-directory-alist '(("." . "~/.saves"))    ; don't litter my fs tree
 delete-old-versions t)

;; https://www.gnu.org/software/emacs/manual/html_node/tramp/Auto_002dsave-and-Backup.html
;; (setq tramp-backup-directory-alist backup-directory-alist)



;; Save a backup everytime. Oddly, emacs defaults to only creating a backup once per session. 
;; https://www.emacswiki.org/emacs/ForceBackups
;; http://stackoverflow.com/questions/6916529/how-can-i-make-emacs-backup-every-time-i-save

;; Tramp buffers are copied from the remote to the local .saves, which can be very slow and doubles the time
;; necessary to save.  Ideally, the local tramp file would be copied locally.  Or fix auto-save-file-name-transforms
;; to not strip the hostname so that the file copy is made locally on whatever host it lives on.

;; http://stackoverflow.com/questions/3893727/setting-emacs-tramp-to-store-local-backups

;; 2017-05-12 disable this because tramp copies the file from the remote to .saves instead of
;; renaming the old tmp file to .saves. Having this on basically doubles the time to save a file.

;; Consider reverting the .saves to be on the remote where tramp can do a rename locally.

;; We want to avoid the "Renaming" step:

;; Saving file /scpx:tlaudeman-dev-v2:/home/ubuntu/todo.txt...
;; Renaming /scpx:tlaudeman-dev-v2:/home/ubuntu/todo.txt to /Users/twl/.saves/!scpx:tlaudeman-dev-v2:!home!ubuntu!todo.txt~...done
;; Copying /var/folders/rq/464nkvvd3k909kgrwnkhy5p80000gp/T/tramp.512ffy.txt to /scpx:tlaudeman-dev-v2:/home/ubuntu/todo.txt...done
;; Wrote /scpx:tlaudeman-dev-v2:/home/ubuntu/todo.txt


;; (add-hook 'before-save-hook  'force-backup-of-buffer)
;; (defun force-backup-of-buffer ()
;;     (setq buffer-backed-up nil))


;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.saves/" t)

;; Align comments within a region. Works fairly well for SQL comments at the ends of lines in create table
;; statements.
;; http://stackoverflow.com/questions/20274336/how-to-automatically-align-comments-in-different-pieces-of-code

;; Name function my- in a valiant attempt not to conflict with functions beginning align-

;; Sep 8 2016 Applies only to SQL, which is the only place I use this function. A comment is " --" and the
;; leading space is required. This will align all comments, so if you have the situation where a comment
;; should be lined up under the field name above, use M-i force-indent to clean up that single line.

(defun my-align-comments (beginning end)
  "Align comments within marked region, especially for SQL create table statements."
  (interactive "*r")
  (let (indent-tabs-mode align-to-tab-stop)
    (align-regexp beginning end "\\(\\s-+\\)\\(\\-\\-\\)+" 1 1 nil)))

;; (defun my-align-comments (beginning end)
;;   "Align comments within marked region, especially for SQL create table statements."
;;   (interactive "*r")
;;   (let (indent-tabs-mode align-to-tab-stop)
;;     (align-regexp beginning end (concat "\\(\\s-*\\)"
;;                                         (regexp-quote comment-start)))))

;; alias my-align-comments to the shorter, more unique myc
(defalias 'myc 'my-align-comments)

;; Align at the space before the second word on the line. Used for the body of SQL create table statements.
;; Name function my- in a valiant attempt not to conflict with functions beginning align-

;; Sep 8 2016 Applies only to SQL. Improved align second word by anchoring to beginning of line.

;; (setq delete-old-versions t
;;   kept-new-versions 6
;;   kept-old-versions 2
;;   version-control t)

;; Code to clean up old backups
;; http://www.emacswiki.org/emacs/BackupDirectory
;; (message "Deleting old backup files...")
;; (let ((week (* 60 60 24 7))
;;       (current (float-time (current-time))))
;;   (dolist (file (directory-files temporary-file-directory t))
;;     (when (and (backup-file-name-p file)
;;                (> (- current (float-time (fifth (file-attributes file))))
;;                   week))
;;       (message "%s" file)
;;       (delete-file file))))

;; Another suggestion Don't clutter with #files either
; (setq auto-save-file-name-transforms
;       `((".*" ,(expand-file-name (concat dotfiles-dir "backups")))))

;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.saves/" t)

(defun mcp (&optional *dir-path-only-p)
  "Copy the current buffer's file path or dired path to `kill-ring'.
Result is full path.
If `universal-argument' is called first, copy only the dir path.
URL `http://ergoemacs.org/emacs/emacs_copy_file_path.html'
Version 2016-07-17"
  (interactive "P")
  (let ((-fpath
         (if (equal major-mode 'dired-mode)
             ;; Emacs sets var default-directory (a directory) for the current buffer
             (expand-file-name default-directory)
           (if (null (buffer-file-name))
               ;; Var buffer-file-name is the full path file name for current buffer
               (user-error "Current buffer is not associated with a file.")
             (buffer-file-name)))))
    (kill-new
     (if (null *dir-path-only-p)
         (progn
           (message "File path copied: %s" -fpath)
           -fpath)
       (progn
         (message "Directory path copied: %s" (file-name-directory -fpath))
         (file-name-directory -fpath))))))

(defalias 'my-copy-path 'mcp)


(defun my-copy-path (&optional *dir-path-only-p)
  "Copy the current buffer's file path or dired path to `kill-ring'.
Result is full path.
If `universal-argument' is called first, copy only the dir path.
URL `http://ergoemacs.org/emacs/emacs_copy_file_path.html'
Version 2016-07-17"
  (interactive "P")
  (let ((-fpath
         (if (equal major-mode 'dired-mode)
             ;; Emacs sets var default-directory (a directory) for the current buffer
             (expand-file-name default-directory)
           (if (null (buffer-file-name))
               ;; Var buffer-file-name is the full path file name for current buffer
               (user-error "Current buffer is not associated with a file.")
             (buffer-file-name)))))
    (kill-new
     (if (null *dir-path-only-p)
         (progn
           (message "File path copied: %s" -fpath)
           -fpath)
       (progn
         (message "Directory path copied: %s" (file-name-directory -fpath))
         (file-name-directory -fpath))))))

(defalias 'mcp 'my-copy-path)


;; This whatever source trees I'm currently using most. Run find-dired, and ignore all the dot files as well as
;; ./tmp/. This gives a clean set of files in a .git directory tree, and ignores non-source files

;; ./doc/* will find the ./doc directory but no files
;; ./doc* won't find the ./doc directory, but will also miss the file document.txt

;; It is probably possible to use a regex and alternation to hide the top level directory but keep
;; files. However, seeing top level directories isn't a problem, so I'm not spending time to work out the
;; -regex solution (if there is one).

(defun mfd ()
  "find-dired starting at the current directory. mfd for my-find-dired."
  (interactive)
  (find-dired "." "-not -path './.*' -not -path './tmp/*' -not -path './images/*' -not -path './target/*' ")
  (rename-buffer 
   (concat 
    "*find-" 
    (progn
      (setq foo (replace-regexp-in-string "/$" "" default-directory))
      (string-match ".*/\\(.*\\)$" foo)
      (match-string 1 foo)))))

;; Align comments within a region. Works well for SQL comments at the ends of lines in create table statements.
;; http://stackoverflow.com/questions/20274336/how-to-automatically-align-comments-in-different-pieces-of-code

;; Name function my- in a valiant attempt not to conflict with functions beginning align-
(defun my-align-comments (beginning end)
  "Align comments within marked region."
  (interactive "*r")
  (let (indent-tabs-mode align-to-tab-stop)
    (align-regexp beginning end 
                  (concat "\\(\\s-*\\)" (regexp-quote comment-start)))))

;; alias my-align-comments to the shorter, more unique mac
(defalias 'mac 'my-align-comments)

;; Align at the space before the second word on the line. Used for the body of SQL create table statements.
;; Name function my- in a valiant attempt not to conflict with functions beginning align-

(defun my-align-second (beginning end) 
 "align on second word"
  (interactive "*r")
  (align-regexp beginning end  "\\([a-z_]+\\)\\(\\s-*\\)\\([a-z_]+\\)" 2 1 nil)
)

;; alias my-align-second to the shorter, more unique mas
(defalias 'mas 'my-align-second)


;; The terminal mode key maps used by ansi-term, eterm, etc. (I think). Char mode is
;; term-raw-map. Line mode is term-mode-map. One way to learn about active maps: C-u M-x
;; is more powerful than plain old M-x. Dunno why.

; C-u M-x apropos-variable RET -mode-map$ RET

;; C-@ .. C-b term-send-raw
;; C-d .. C-w	term-send-raw
;; C-y .. C-z	term-send-raw
;; C-\ .. DEL	term-send-raw

(defun xf ()
  ""
  (interactive)
  (term-send-raw-string "f"))

(defun my-shell-setup ()
  "Tom's term that really works"

  (local-set-key "\C-x f" 'xf)

  ;; (define-key term-raw-map [(control ?a)] 'term-send-raw)
  ;; (define-key term-raw-map "\M-`" 'other-frame)
  ;; (define-key user-minor-mode-map "\C-x" 'term-send-raw)
  ;; (define-key user-minor-mode-map "\C-p" 'term-send-raw)

  ;;   (suppress-keymap term-raw-map)
  ;;(define-key global-map "\C-x b" 'term-send-eof)
  ;; (local-set-key KEY COMMAND)

  ;;(local-set-key "\C-p"  'term-send-raw)  

  ;; (define-key term-raw-map "\C-c\C-d" 'term-send-raw)
  ;; (define-key term-mode-map "\C-c\C-d" 'term-send-raw)
  (user-minor-mode 0)
  (message "Done running my-shell-setup.")
  )

(add-hook 'term-mode-hook 'my-shell-setup)

;; Weird Mac stuff.
;; http://www.emacswiki.org/emacs/MetaKeyProblems#toc15
;; http://www.emacswiki.org/emacs/CarbonEmacsPackage
;; http://xahlee.info/emacs/emacs_hyper_super_keys.html

;; values: super, hyper, meta, control, nil

;; I didn't try global-set-key. Maybe it would work. I switched to
;; define-key and the user-minor-mode-map so that my keybindings would
;; override all the goofy mode maps (like the HTML mode map).
;; (global-set-key [s-p] 'down-one)

(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)
(setq mac-function-modifier 'control)

;; re: gpg The daffy Mac and Aquamacs don't read .bash_profile and .bashrc
;; like the rest of the planet. You could go down the rabbit hole
;; http://developer.apple.com/library/mac/#qa/qa1067/_index.html
;; Instead, just get Emacs to add stuff to your path. The Mac GPG
;; tools are in /usr/local/bin.

;; Nov 21 2015
;; gnupg from pkgin is /opt/pkg/bin/gpg

;; http://lists.gnu.org/archive/html/help-gnu-emacs/2011-04/msg00210.html

(setenv "PATH" (concat "/usr/local/bin" path-separator (getenv "PATH")))
(setenv "PATH" (concat "/opt/pkg/bin/" path-separator (getenv "PATH")))
(setenv "PATH" (concat (getenv "HOME") "/bin" path-separator (getenv "PATH")))

;; http://www.andreas-wilm.com/src/dot.emacs.html
;; This would work too, but has the path separator hard coded.
;; (setenv "PATH" (concat (getenv "PATH") ":/opt/local/bin"))

;; Andreas says: delete next line and you get: *ERROR*: Searching for
;; program: No such file or directory, gpg. 

;; You must open a shell and determine the correct path to gpg
;; manually, then put that path in the line below.

(setq exec-path (append exec-path '("/Users/twl/bin")))
(setq exec-path (append exec-path '("/usr/local/bin")))
(setq exec-path (append exec-path '("/opt/pkg/bin")))

;; New emacs (or Aquamacs?) suddenly defaulted to bar instead of box. 
;; http://www.gnu.org/software/emacs/manual/html_node/elisp/Cursor-Parameters.html
(setq-default cursor-type 'box) 

; Set cursor color
(set-cursor-color "#660099")

;; enable/disable menu bar and tool bar. Oddly, it is necessary to use
;; (tool-bar-mode 0) because nil doesn't work, contrary to what the
;; docs say.
;; (tool-bar-mode 0)

; (menu-bar-mode 0)

;; Show which function the cursor is in.
(which-function-mode t)

;; default the cursor to blinking.
(blink-cursor-mode t)

;; default is 10
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Cursor-Display.html
(setq blink-cursor-blinks 0)

;; Tell the man-page functions woman* to open documents in the same
;; frame, not a new frame.
(setq woman-use-own-frame nil)

;; Save/restore desktop from the launch directory. Normally you
;; disable at launch with --no-desktop, but I've added code below to
;; do things a little differently.
;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Saving-Emacs-Sessions.html

;; Alternate convention for desktop saving. If .emacs.desktop exists,
;; then go into desktop-save-mode, otherwise not. For dirs where I
;; want a desktop file, I'll run the "touch .emacs.desktop" before
;; starting emacs. Most dirs I don't want a desktop.

;; If your messages say: 'Wrong type argument: listp, "."' then the
;; problem is that desktop-path is "." instead of the correct '(".")
;; and the error is coming from desktop-read, not
;; desktop-save-mode. Emacs automatically calls desktop-read at some
;; point after reading the .emacs file. The late call makes the
;; problem difficult to debug since the error message doesn't give
;; hints as to what code generated it. I had a condition-case around
;; desktop-save-mode, but that didn't do anything because the error
;; was later.

(if (file-exists-p ".emacs.desktop")
    (progn (setq desktop-path '("."))
	   (desktop-save-mode 1)
	   )
  )

;; I wonder what this does? It appeared at the bottom of the file which implies that I saved some settings and
;; emacs saved this setting for me.

(put 'narrow-to-region 'disabled nil)

;; Enable auto-complete mode

(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories "~/.emacs.d/lisp/ac-dict")
  (ac-config-default)
  (ac-set-trigger-key "TAB"))

;; (load "nxhtml/autostart")

(safe-require 'undo-tree)

;; https://github.com/browse-kill-ring/browse-kill-ring

(when (safe-require 'browse-kill-ring)
  (browse-kill-ring-default-keybindings))

(safe-require 'multi-term)

; Replace $RSENSE_HOME with the directory where RSense was installed in full path
;; Example for UNIX-like systems
;; (setq rsense-home "/home/tomo/opt/rsense-0.2")
;; or
;; (setq rsense-home (expand-file-name "~/opt/rsense-0.2"))
;; Example for Windows
;; (setq rsense-home "C:\\rsense-0.2")

(setq rsense-home "~/opt")
(add-to-list 'load-path (concat rsense-home "/etc"))
(safe-require 'rsense)

;; Enable downcase-region (and apparently upcase-region). I don't know why this would be
;; disabled by default, but it is. Something about "confusing to new users". I don't have
;; it bound to a key, but I use it, especially in keyboard macros, so it needs to be
;; working.

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Skip the startup "message", which looks like a "screen" or
;; "splash". Whatever. This makes it not appear.
(setq inhibit-startup-message t)

;; Not sure what these skip, but I doubt I want to see the splash or startup screen.
;; Non-nil inhibits the startup screen.  It also inhibits display of the initial message
;; in the `*scratch*' buffer.
(setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)

;; http://www.emacswiki.org/emacs/CuaMode
;; http://www.gnu.org/software/emacs/manual/html_node/emacs/CUA-Bindings.html
;; New register binding are added to cua mode because C-x conflicts
;; with the normal register commands. Use C-1 C-c to copy to register
;; 1. Use C-1 C-v to paste the contents of register 1. M-x
;; copy-to-register still works.

;; Disable cua-mode by default. As clever as it may seem for C-x to be "copy" in every application, it is not universal,
;; and I'm too used to C-x as the prefix for all kinds of things.

(condition-case err
    (cua-mode 0)
  (error "Cannot enable cua mode"))

;; Don't tabify after rectangle commands
(setq cua-auto-tabify-rectangles nil)

;; No region when it is not highlighted
(transient-mark-mode 1) 

;; Standard Windows behaviour is t, but since I usually use a C-x
;; command immediately after copy, I have it set to nil
(setq cua-keep-region-after-copy nil)

;; Makes killing/yanking interact with X clipboard and X11 selection. There
;; are several other settings that deal wit the "X selection" which is
;; not quite the same as the X clipboard.
;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Cut_002fPaste-Other-App.html
(setq x-select-enable-clipboard t)  

;; Enable ido-mode for fancy completion on buffer switch and file
;; open. We don't seem to need the require 'ido in recent versions of
;; Emacs.  http://www.emacswiki.org/cgi-bin/wiki/InteractivelyDoThings
(condition-case err
    (ido-mode t)
  (error "Cannot enable ido mode"))

;; Tell emacs that read-only files whether write protected on disk or
;; set to read-only via toggle-read-only are *not* editable.  The
;; normal "can't edit" was broken somewhere around version 22.1.1 and
;; now it insists on using the version control system (which doesn't
;; work either).
(setq view-mode-only t)

;; re: font-lock (aka hilite, highlighting, colorized text, color) I decided to bind the
;; toggle to a key. Therefore the default is on, but I generally turn it off with C-xt.

;; Feb 1 2016 Change default to disabled. This works for .emacs, .php, .pl When emacs launches and uses
;; .emacs.desktop, the files are opened with font-lock disabled. That is, no syntax highlighting. Newly opened
;; files are also monochrome.
(global-font-lock-mode 0)

;; Apparently, nil is "enable". 
;; (global-font-lock-mode nil)

;; This does not prevent perl-mode from enabling font-lock.
(setq font-lock-global-modes '(not perl-mode))

;; js2-mode breaks standard font lock in some new way, but is easily fixed.
;; http://steve-yegge.blogspot.com/2008/03/js2-mode-new-javascript-mode-for-emacs.html
(setq js2-use-font-lock-faces t)

(setq js2-highlight-level nil)

;; Paste (yank) at the text cursor location, not at the 
;; location of the mouse pointer. This only applies to graphical (X)
;; emacs sessions. 
(setq mouse-yank-at-point t)

;; Disable the nasty zmacs region highlighting in xemacs. Having it on
;; breaks mark-search-cut behavior. 
(setq zmacs-regions nil)

;; ispell settings jul 16 2015
(setq ispell-program-name "aspell")
(setq ispell-program-name "/usr/pkg/bin/aspell")

;; Uncomment to automatically load ispell at startup.
;(load "ispell")

;; Uncomment for hexl. It seems better to just manually switch to hexl-mode via C-x.

;(autoload 'hexl-find-file "hexl" "Edit file FILENAME in hexl-mode." t)
;(define-key global-map "\C-c\C-h" 'hexl-find-file)

;; Uncomment if you like lots of backup versions
;(setq version-control t)

;; Stop emacs from automatically converting end of line characters.
;; Auto converting Windows or Mac eol to Linux eol can be really, really
;; confusing.
(setq inhibit-eol-conversion t)

;; Prevent loading default.el. 
(setq inhibit-default-init 1)

;; valid values for require-final-newline
;; nil
;; t
;; (quote query)
(setq require-final-newline nil)

;; In customization group Editing Basics, Line Move Visual controls
;; whether or not the cursor moves to logical lines or visual
;; lines. The difference is for continuation lines, the visual line is
;; the next line on the screen. The logical line is the next actual
;; line in the file, and not necessarily what is "visual" on the
;; screen. This should not be confused with visual line mode.

;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Continuation-Lines.html
;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Visual-Line-Mode.html#Visual-Line-Mode

;; Keywords: line wrap, wrapping, continuation, visual, logical,
;; cursor, cursor jump, cursor skip, skip line, skip continuation,
;; wrapped lines, continuation lines, line continuation, line
;; continuation mode, cursor movement mode, cursor mode, next line,
;; next logical line, skip to logical line, cursor move, line visual
;; move, line-move-visual, move logical, logical lines

;; http://braeburn.aquamacs.org/code/master/aquamacs/doc/AquamacsHelp/node40.html
;; Starting around version 23.3.50 the default seems to have change to
;; some kind of wrapping for text files.
(setq auto-word-wrap-default-function nil)

;; Important. http://stackoverflow.com/questions/683425/globally-override-key-binding-in-emacs
;; I think this allows my preferred mode map to continue working when
;; other minor modes are active. See my user-minor-mode-map define-key
;; bindings below at "Core key bindings below". 

(defvar user-minor-mode-map (make-sparse-keymap) "user-minor-mode keymap.")

(define-minor-mode user-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  t
  " user-keys"
  'user-minor-mode-map)

;; Turn user-minor-mode on/off 1/0 in the mini-buffer.
;; Oct 5 2009 Was 1 which was clearly a mistake. 

(defun user-minibuffer-setup-hook ()
  (user-minor-mode 0))

(add-hook 'minibuffer-setup-hook 'user-minibuffer-setup-hook)

(user-minor-mode 1)

(defun noop ()
  "Placeholder for noop key bindings."
  (interactive)
  (message "key not defined")
  )


;; http://www.emacswiki.org/emacs/UnfillParagraph

;; A unfill-paragraph that works in lisp modes
(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

;; Core key bindings begin here. 

;; Replace C-w kill-region with a defun that only kills the active region, and does not kill to the mark when
;; not active. Killing to the mark when no active selection is really irritating, and I'm fairly sure I never
;; want to do that. Or very rarely. If I want to kill to the mark, C-x C-x (exchange-point-and-mark) then C-w will do it.

(defun kill-active-region () 
 "kill region if active only or kill line normally"
  (interactive)
  (if (region-active-p)
      (call-interactively 'kill-region)))

(global-set-key (kbd "C-w") 'kill-active-region)


;; Unbind the key to center text. Too close to M-C-s and I never use
;; it. Disable.  In a lisp eval window, it didn't like the usual shortcuts for
;; Meta, so I just inserted an escape char. (Why is this now commented out?)
; (define-key user-minor-mode-map "s" 'noop)

;; Make the "delete" key in the cursor key (aka key pad) area perform a forward
;; delete, backspace (the key above \) performs a backward delete. Sadly,
;; [delete] and [kp-delete] can be different and can be aliased to something
;; else, therefore you must re-bind them separately. (Apple in their bizarre
;; wisdom have written "delete" on the backspace key.)

;; Using the syntax (square brackets): [delete], [DEL], and [\d] did not work.

;; Do not use "\d" because \d is some weird alias for whatever Emacs thinks is
;; the local definition of the delete key. That local definition is often wrong.

;; (define-key global-map "\d" 'delete-char)

;; For Aquamacs and anything else, meta backtick switches Emacs frames ala
;; meta-tab switching windows.
(define-key global-map "\M-`" 'other-frame)

;; Set a couple of mouse related events in the fringe which is the one character wide column at the edge of
;; the buffer window. drag region causes the highlight to follow the mouse action. set region copies the
;; region. My settings seem to cause the region *not* to be automatically copied into the kill ring. I have to
;; kill-region C-w or kill-ring-save M-w.
(global-set-key (kbd "<left-fringe> <down-mouse-1>") 'mouse-drag-region)
(global-set-key (kbd "<left-fringe> <drag-mouse-1>") 'mouse-set-region)


(define-key global-map [delete] 'delete-char)
(define-key global-map [kp-delete] 'delete-char)
(define-key global-map [backspace] 'backward-delete-char)

;; The global-map is overridden by the minibuffer-local-map. When I
;; fixed the stupid Mac delete, it broke backspace in the
;; minibuffer. This fixes both keys for the minibuffer.

(define-key minibuffer-local-map [delete] 'delete-char)
(define-key minibuffer-local-map [kp-delete] 'delete-char)
(define-key minibuffer-local-map [backspace] 'backward-delete-char)

(define-key isearch-mode-map '[backspace] 'isearch-delete-char)

;; I think this works now that the key spec is correct. Old comment:
;; none of this works to absolutely map my keys. other modes are
;; taking over my key mapping

(defun beginning-of-defun-one ()
  "beginning of inner defun or function"
  (interactive)
  (beginning-of-defun 1))

(defun end-of-defun-one ()
  "end of inner defun or function"
  (interactive)
  (end-of-defun 1))

;; This seems to work.
(global-set-key "\C-[t" 'noop)
(global-set-key "\C-z" 'undo)

;; This seems to work too, and uses the (kbd) macro which seems handy.
(global-unset-key (kbd "M-k"))
(global-unset-key (kbd "C-_"))
(global-unset-key (kbd "C-/"))



;; Unbind M-delete in the form of C-[-delete which (at least on the
;; Mac with standard Emacs) is different from M-delete. Both key
;; bindings are a huge headache since I hit them fairly often by
;; accident.
(global-unset-key (kbd "M-"))

;; Ditto C-x delete. This is also a bad one to hit accidentally.
(global-unset-key "\C-x")

;; Another bad key combination to hit by accident. The Lisp debugger
;; wouldn't let me write this "\C-". Oddly, this is already remapped
;; in the user-minor-mode-map which will take precedence over the
;; global key binding.
(global-unset-key [C-delete])

;; replace all the upcase-whatever keys because I confuse them with backward-up-list, and it is easy to M-x upcase-region.
(define-key user-minor-mode-map "\C-xu" 'backward-up-list)
(define-key user-minor-mode-map "\C-x\C-u" 'backward-up-list)

;; This seems to work too, although it rebinds the key to my defun
;; noop (as opposed to unbinding the key or binding to nil), and
;; global-unset-key can't unbind what this does.
(define-key global-map "\C-[t" 'noop)
(define-key user-minor-mode-map  "\C-[t" 'noop)



;; This can be typed as M-u or \C-[ u
(define-key user-minor-mode-map "\C-[u" 'backward-up-list)
(define-key user-minor-mode-map "\C-[\C-a" 'beginning-of-defun-one)
(define-key user-minor-mode-map "\C-[\C-e" 'end-of-defun-one)
;; (global-set-key "\C-[\C-a" 'beginning-of-defun-one)

(define-key user-minor-mode-map "\C-[i" 'force-indent)
(define-key user-minor-mode-map [delete] 'delete-char)
(define-key user-minor-mode-map [kp-delete] 'delete-char)
(define-key user-minor-mode-map [backspace] 'backward-delete-char)

(define-key user-minor-mode-map "\C-x\C-d" 'dired)
(define-key user-minor-mode-map "\C-xt" 'font-lock-mode)

;; I never use this after discovering M-; comment-dwim. These two key bindings
;; could be repurposed.

(define-key user-minor-mode-map "\C-[#" 'comment-region)
(define-key user-minor-mode-map "\C-x#" 'comment-region)

;; Make isearch the default search. Nov 1 2012 is the day I finally saw the
;; light and switch over my key bindings to this far more sensible approach.

(define-key user-minor-mode-map "\C-s" 'isearch-forward)
(define-key user-minor-mode-map "\C-r" 'isearch-backward)
(define-key user-minor-mode-map "\C-[\C-s" 'search-forward)
(define-key user-minor-mode-map "\C-[\C-r" 'search-backward)

(define-key user-minor-mode-map "\C-x\C-n" 'next-error)
(define-key user-minor-mode-map "\C-x\C-p" 'previous-error)
(define-key user-minor-mode-map "\C-xc" 'compile)
(define-key user-minor-mode-map "\C-h" 'backward-delete-char)
(define-key user-minor-mode-map "\C-[g" 'goto-line)
(define-key user-minor-mode-map "\C-xn" 'other-window)
(define-key user-minor-mode-map "\C-[q" 'query-replace)
(define-key user-minor-mode-map "\C-xf" 'find-file)
(define-key user-minor-mode-map "\C-[\C-[" 'repeat-complex-command)
(define-key user-minor-mode-map "\C-[r" 'replace-string)
(define-key user-minor-mode-map "\C-[f" 'fill-paragraph)
(define-key user-minor-mode-map "\C-z" 'undo)

;; Setting keys to nil did not work. They still kept their default
;; actions.  C-S-backspace is control-shift-backspace. I hit
;; C-backspace accidentally which was confusing.

(define-key user-minor-mode-map [C-S-backspace] 'delete-backward-char) 
(define-key user-minor-mode-map [C-backspace] 'delete-backward-char)
(define-key user-minor-mode-map [M-backspace] 'delete-backward-char)
(define-key user-minor-mode-map [insert] nil)
(define-key user-minor-mode-map [insertchar] nil)

;;  Remap keys using lowercase "L" (ell, l). I'm always hitting these instead of
;;  C-l. Possibly C-xl might be ok. I guess l is for "lower", but it should be d for
;;  "downcase". Standard binding for \C-l is to recenter-top-bottom.

(define-key user-minor-mode-map "\C-[l" 'recenter)
(define-key user-minor-mode-map "\C-x\C-l" 'recenter)
(define-key user-minor-mode-map "\C-l" 'recenter)

;; was scroll-down-command and of course was often confused with paste.
(define-key user-minor-mode-map (kbd "M-v") 'yank)
;; Jan 22 2014 I just noticed that C-v was still bound to the built-in scroll-up. C-v is paste in most apps,
;; and scroll-up is broken so it makes 2x sense to update the key binding.
(define-key user-minor-mode-map (kbd "C-v") 'yank)

;; was capitalize-word and was often confused with copy.
(define-key user-minor-mode-map (kbd "M-c") 'kill-ring-save)

;; Can't remap M-x because it execute-extended-command, which we kind of need to leave alone.

;;  Use a new function for page up and page down.  This one will place the cursor on the
;;  line where you started if you do the opposite. The default Emacs scroll-up and
;;  scroll-down don't return the cursor to the same line. That's bad.  This still doesn't
;;  work quite right if you hit the top or bottom of the buffer.  That could be fixed by
;;  remembering how far the last scroll was, and reversing when necessary.

(define-key user-minor-mode-map "\C-[a" 'backward-screen)
(define-key user-minor-mode-map "\C-[z" 'forward-screen)
(define-key user-minor-mode-map [(prior)]   'backward-screen)
(define-key user-minor-mode-map [(next)]   'forward-screen)
(define-key user-minor-mode-map "\C-[p" 'down-one)
(define-key user-minor-mode-map "\C-[n" 'up-one)
(define-key user-minor-mode-map "\C-p" 'down-one)
(define-key user-minor-mode-map "\C-n" 'up-one)
(define-key user-minor-mode-map "\C-xp" 'scroll-style)

;;  Use new kdb syntax available as of 19.30
;;  http://tiny-tools.sourceforge.net/emacs-keys.html

;; The next 4 functions allow page up and page down, keeping the cursor in the same relative position on the
;; screen. This was a huge pita because after scrolling, emacs recenters the screen. move-to-window-line and
;; foward-line would always fail to keep the relative cursor position at some point due to auto recentering.
;; The solution is to call recenter with the relative cursor line position offset.

(defun relative-line ()
  "Get the relative line number from top of the window."
  (interactive)
  (let* ((clines (line-number-at-pos))
         (ws-pos (line-number-at-pos (window-start))))
    (if (< clines (window-height))
        clines
      (+ 1 (mod clines ws-pos)))))

(defun half-window ()
  "Integer rounded half window height"
  (interactive)
  (round (- (/ (window-height) 2.0) 0.1)))

(defun forward-screen ()
  "Scroll down one screen in display."
  (interactive)
  (let* ((rel-line (- (relative-line) 1))
         (forw-line (- (window-height) 3)))
    (progn
      (forward-line forw-line)
      (recenter rel-line))))

(defun backward-screen ()
  "Scroll up one screen in display."
  (interactive)
  (let* ((rel-line (- (relative-line) 1))
         (forw-line (- (- (window-height) 3))))
    (progn
      (forward-line forw-line)
      (recenter rel-line))))


;; May 19 2015 What about M-\ delete-horizontal-space? Seems to work just fine as unindent.

;; Or M-^ delete-indentation

;; sep 19 2008 Could bind unindent and force-indent to keys, or just
;; create a keyboard macro everytime I need one of them.

(defun unindent ()
  "Remove whitespace from the beginning of a line."
  (interactive)
  (beginning-of-line)
  (re-search-forward "^[ 	]*")
  (replace-match ""))

(defun force-indent ()
  "Remove leading whitespace and insert a tab."
  (interactive)
  (unindent)
  (indent-relative)
  )

;;  man page mode uses one of my favorite key bindings. Over load it's function with
;;  mine. Switching my key bindings to user-minor-mode-map may have fixed this.

(defun Man-next-manpage ()
  "overload"
  (interactive)
  (up-one))

(defun Man-previous-manpage ()
  "overload"
  (interactive)
  (down-one))

(setq scroll-style-flag nil)

(defun scroll-style ()
  "Toggle between screen and line scrolling."
  (interactive)
  (setq scroll-style-flag (not scroll-style-flag))
  (message (format "scroll-style set to %s" scroll-style-flag ))
  )

(defun up-one ()
  "scroll text up one line in display, or cursor one line down."
  (interactive)
  (let ((sd_ok nil))
    ;; scroll-up moves the cursor if the cursor is at line 1. If we
    ;; don't compensate then next-line below will also move the curosr
    ;; and we'll move 2 lines, but only on line 1.
    (if (and scroll-style-flag (> (line-number-at-pos) (line-number-at-pos (window-start))))
	(condition-case err
	    (progn
	      (scroll-up 1)
	      (setq sd_ok t)
	      ;; (message "scroll text")
	      )
	  ;;(error (message "err"))
	  )
      )
    ;; always move the cursor by one line
    ;; (message "next line")
    (next-line 1)
    (if sd_ok (recenter))
    )
  )

(defun down-one ()
  "scroll text down one line in display, or cursor one line up."
  (interactive)
  (let ((sd_ok nil))
    (if scroll-style-flag
	(condition-case err
	    (progn
	      (scroll-down 1)
	      (setq sd_ok t)
	      ;; (message "scroll text down")
	      )
	  ;; scroll-down is subtly different from scroll-up and this
	  ;; error trap is necessary so that errors in scroll-down
	  ;; don't cause the defun to simply exit. We need the rest of
	  ;; the defun to finish, even if scroll-down threw an error.
	  (error ())
	  )
      )
    ;; always move the cursor by one line
    ;; (message "prev line")
    (previous-line 1)
    (if sd_ok (recenter))
    )
  )


;; Two functions that enable editing delimiter separated values (dsv, comma separated values or tab separated
;; values) in org mode.

;; Open the dsv file. In the buffer run my-edit-dsv-as-orgtble, save as normal and the file is written back as
;; dsv, and the buffer reverted to dsv.

;; Optionally bind to a key:

;; Open the current TSV file as an Org table
;; (global-set-key (kbd "C-c |") 'my-edit-dsv-as-orgtbl)

;; http://emacs.stackexchange.com/questions/1027/setting-or-simple-mode-for-editing-tab-separated-columns

(defun my-export-to-parent ()
  "Exports the table in the current buffer back to its parent DSV file and
    then closes this buffer."
  (let ((buf (current-buffer)))
    (org-table-export parent-file export-func)
    (set-buffer-modified-p nil)
    (switch-to-buffer (find-file parent-file))
    (kill-buffer buf)))

(defun my-edit-dsv-as-orgtbl (&optional arg)
  "Convet the current DSV buffer into an org table in a separate file. Saving
    the table will convert it back to DSV and jump back to the original file"
  (interactive "P")
  (let* ((buf (current-buffer))
         (file (buffer-file-name buf))
         (txt (substring-no-properties (buffer-string)))
         (org-buf (find-file-noselect (concat (buffer-name) ".org"))))
    (save-buffer)
    (with-current-buffer org-buf
      (erase-buffer)
      (insert txt)
      (org-table-convert-region 1 (buffer-end 1) arg)
      (setq-local parent-file file)
      (cond 
       ((equal arg '(4)) (setq-local export-func "orgtbl-to-csv"))
       ((equal arg '(16)) (setq-local export-func "orgtbl-to-tsv"))
       (t (setq-local export-func "orgtbl-to-tsv")))
      (add-hook 'after-save-hook 'my-export-to-parent nil t))
    (switch-to-buffer org-buf)
    (kill-buffer buf)))


;; This error catching block exists because some settings are not portable across platforms and I don't like
;; fatal errors in this file. Emacs saving customizations doesn't understand custom-set-variables when it is
;; inside another block, so if you save you'll have to manually copy the new setting here.

(condition-case err
    (custom-set-variables
     '(cua-mode nil nil (cua-base))
     '(ess-S-assign "_")
     '(ido-everywhere t)
     '(ido-show-dot-for-dired t)
     '(line-move-visual nil)
     '(php-template-compatibility nil)
     '(mode-line-format
       (quote
        ("%e" mode-line-front-space mode-line-mule-info mode-line-client mode-line-modified mode-line-remote mode-line-frame-identification mode-line-buffer-identification "   " mode-line-position
         (vc-mode vc-mode)
         "  " mode-line-modes mode-line-misc-info default-directory mode-line-end-spaces)))

     ;; term-bind-key-alist and term-unbind-key-list only apply to
     ;; multi-term.el.

     '(term-bind-key-alist
       (quote (
	       ("C-c C-x b" . switch-to-buffer)
	       ("C-c M-x" . execute-extended-command)
	       ("C-c C-c" . term-interrupt-subjob)
	       ;; M-` is very Mac-ish and may not the best key binding on other systems
	       ("M-`". other-frame)
	       ("C-m" . term-send-raw)
	       )
	      )
       )
     '(term-unbind-key-list (quote ("C-c")))
     )
  (error ))

;; Operating system dependencies. 

;; We have two possible :background colors. The same two colors apply to both operating systems. Each os has a
;; different custom-set-faces. After setting the os specific customizations, both use the same command to set
;; the :background. Many settings are the same. The fonts are the big os specific issue. Could separate those
;; out, although this works.

(let ((bg_color "white"))
  (if (string= window-system nil)
      ;; (setq bg_color nil))
      (custom-set-faces
       '(default ((t (:inherit nil :stipple
                               nil :background "brightwhite" :foreground "black" :inverse-video
                               nil :box nil :strike-through nil :overline nil :underline
                               nil :slant normal :weight normal :height 151 :width
                               normal :foundry "bitstream" :family "Courier 10 Pitch"))))
       )
    ;; else
    (if (string= system-type 'darwin )
        ;; Mac OSX darwin
        (custom-set-faces
         '(default ((t (:inherit nil :stipple
                                 nil :background "white" :foreground "black" :inverse-video
                                 nil :box nil :strike-through nil :overline nil :underline
                                 nil :slant normal :weight normal :height 180 :width
                                 normal :foundry "nil" :family "Courier"))))
         ;; Inconsolata has incomplete unicode glyphs.
         ;; '(default ((t (:inherit nil :stipple
         ;;                         nil :foreground "black" :inverse-video nil :box
         ;;                         nil :strike-through nil :overline nil :underline
         ;;                         nil :slant normal :weight normal :height 210 :width
         ;;                         normal :foundry "apple" :family "Inconsolata"))))
         )
      ;; else Linux
      (custom-set-faces
       '(default ((t (:inherit nil :stipple
                               nil :background "white" :foreground "black" :inverse-video
                               nil :box nil :strike-through nil :overline nil :underline
                               nil :slant normal :weight normal :height 151 :width
                               normal :foundry "bitstream" :family "Courier 10 Pitch"))))
       ;; (default ((t (:inherit nil :stipple
       ;;                        nil :foreground "black" :inverse-video nil :box
       ;;                        nil :strike-through nil :overline nil :underline nil :slant
       ;;                        normal :weight normal :height 136 :width
       ;;                        normal :foundry "urw" :family "Nimbus Mono L"))))) 
       )
      ;; Since custom-set-faces doesn't like variables, use set-face-attribute.
      (set-face-attribute 'default nil :background bg_color)
      )))

;;http://code.google.com/p/js2-mode/wiki/InstallationInstructions

(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; Below are notes of things that didn't work. Perhaps this will be useful someday to
;; someone.

;; http://amitp.blogspot.com/2007/03/emacs-move-autosave-and-backup-files.html
;; Running these manually in *scratch* gives:
;; user-temporary-file-directory
;; nil
;; "/var/folders/3M/3M+5Z2l7FtaCjIk8KrqGLU+++TI/-Tmp-/mst3k/.auto-saves-"
;; ((".*" "/var/folders/3M/3M+5Z2l7FtaCjIk8KrqGLU+++TI/-Tmp-/mst3k/" t))

;; This didn't work. # files are still saved on the remote with fuse:
;; lrwxrwxrwx  1 merry.terry merry.terry        26 2012-03-15 10:02 .#rc_notes.php -> mst3k@zeus.westell.com.454

;; http://stackoverflow.com/questions/5738170/why-does-emacs-create-temporary-symbolic-links-for-modified-files

;; (defvar user-temporary-file-directory
;;   (concat temporary-file-directory user-login-name "/"))
;; (make-directory user-temporary-file-directory t)
;; (setq auto-save-list-file-prefix
;;       (concat user-temporary-file-directory ".auto-saves-"))
;; (setq auto-save-file-name-transforms
;;       `((".*" ,user-temporary-file-directory t)))

;; this didn't seem to fix the auto save problem.
;; (setq tramp-auto-save-directory "~/.saves")

;; Still doesn't stop creation of symlinks of changed files.

;;(safe-require 'inhibit-clash-detection)
;; (setq inhibit-clash-detection t)

;; http://snarfed.org/gnu_emacs_backup_files
;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.emacs.d/.
;; (custom-set-variables
;;   '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
;;   '(backup-directory-alist '((".*" . "~/.emacs.d/backups/"))))
;; ;; create the autosave dir if necessary, since emacs won't.
;; (make-directory "~/.emacs.d/autosaves/" t)


;; from defun my-shell-setup

;; didn't work when the minor mode was disabled
;; (local-set-key "\C-x"  'term-send-raw)  

;; doesn't work
;; (define-key term-raw-map "\C-x" 'term-send-raw)

;; doesn't work
;; (define-key term-mode-map "\C-x" 'term-send-raw)

;; end defun my-shell-setup

;; values: super, hyper, meta, nil

;; Since using define-key here doesn't work, I'm guessing that the
;; super key binding happens after .emacs is loaded.

;; doesn't work 
;;(define-key user-minor-mode-map "s-p" 'down-one)

;; http://www.nongnu.org/emacs-tiny-tools/keybindings/index-body.html
;; Does not work in gnu emacs 23.1.1
;; (setq delete-key-deletes-forward t)

;; Edifying code fragments. Not useful:

;; (condition-case err
;;     (desktop-save-mode 1)
;;   (error (message "error: %s" (error-message-string err)))
;;   )

;; More useful, but pointless once you know that desktop-read is
;; emitting the error:

;; (condition-case err
;;     (desktop-read)
;;   (error (message "error: %s" (error-message-string err)))
;;   )

;; This works, but my new func safe-require is better.

;; (when (require 'undo-tree nil t)
;;   (princ "undo-tree loaded")
;;   )

;; EasyPG is part of Emacs from v 22 on (or is that 23?), so don't
;; enable it, and absolutely do not install the standalone. Installing
;; the standalone breaks the internal functions.

;; Disable the damnable hard to read colorized source code, aka syntax highlighting aka
;; font lock mode.  Automatically becomes buffer-local when set in any fashion, so you
;; have to use the global version of the function. For more info do describe-function on
;; font-lock-mode (Yes, there is a variable and a function with the same name,
;; apparently.) This does not work: (setq font-lock-mode nil) Emacs gets upset when
;; calling the function global-font-lock-mode with an arg nil, so I call it with zero and
;; that's fine. All this time I thought nil was a value.

;; This works now that the defun is correct. Don't need it, but I've
;; left it here for historical purposes.
;; (defun turn-off-font-lock ()
;;    "Disable font-lock-mode"
;;  (interactive)  
;;    (font-lock-mode nil))
;; (add-hook 'perl-mode-hook 'turn-off-font-lock)

;;  None of these work in -nw
;; ;(define-key user-minor-mode-map (kbd "C-S-N") 'up-one)
;; ;(define-key user-minor-mode-map (kbd "C-S-P") 'down-one)
;; ;(global-set-key [(control shift n)] 'up-one)
;;  (list ?C-S-n (type-of ?C-S-n)) 
;;  (list ?C-n (type-of ?C-n)) 
;; ;;(define-key user-minor-mode-map (kbd "C-N") 'up-one)
;; ;;(define-key user-minor-mode-map (kbd "C-P") 'down-one)

;; doesn't work 
;;(define-key user-minor-mode-map "s-p" 'down-one)

;; (Solved by not using xemacs.) Stupid xemacs can't grok "\C-[\C-[" which I've used for
;; repeat-complex-command for many years, so re-purpose C-x[ It normally means page up,
;; but I always use something else for page up.
; (define-key user-minor-mode-map "\C-x\["
;  'repeat-complex-command) (global-set-key "\C-x\["
;  'repeat-complex-command)

;; sep 15 2011 Make all scrolling up and down go through up-one and down-one and use a var
;; and function to toggle whether or not scrolling is normal cursor move, or scrolling the
;; screen and keeping the cursor in the middle. Default to normal (traditional scrolling)
;; style

;; http://scottmcpeak.com/elisp/scott.emacs.el

;; (defun line-of-position (pos)
;;   "Return the 1-based line number of the given position."
;;   (count-lines (point-min)
;;                (if (>= pos (point-max))
;;                    (point-max)
;;                    (+ pos 1))
;;   ))

;; This is an example of keyboard rebinding on the Macintosh.  I've preserved this for
;; historical interest only.  It makes these assignments: F5 splits the display vertically
;; F6 enlarges the window containing the cursor F7 shrinks the window containing the
;; cursor F8 eliminates all split windows See the file ~/lisp/mac/Macintosh-win.el for the
;; codes to define other keys.

; (setq mac-raw-map-hooks
; 	  (list
; 	   '(define-key mac-raw-map "\040" 'split-window-vertically)
; 	   '(define-key mac-raw-map "\041" 'enlarge-window)
; 	   '(define-key mac-raw-map "\042" 'shrink-window)
; 	   '(define-key mac-raw-map "\044" 'delete-other-windows)))


;; The code below (when uncommented) creates an irritating bug in that
;; it overrides custom-font-faces when first loaded, but allows
;; custom-font-faces to work when loaded via load-file. I'm fairly
;; certain the the code below was a poor work-around for default font
;; loading.

;; (assq-delete-all 'font default-frame-alist)
;; (add-to-list
;;  'default-frame-alist
;;  '(font . "-Adobe-Courier-Medium-R-Normal--17-120-100-100-M-100-ISO8859-1"))

;; The font below was present in Fedora 6, but not in Fedora 8
;; Why did the available fonts change?
;;   '(font . "-Adobe-Courier-Medium-R-Normal--14-140-75-75-M-90-ISO8859-1"))

;; Unset certain undo bindings that are irritating to hit accidentally.

;; (define-key user-minor-mode-map "\C-_" 'noop)
;; (define-key user-minor-mode-map "\C-\\" 'noop)
