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


