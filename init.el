; ==============================================================================
;                           init.el by John Ankarström
; ==============================================================================

;; 1. Packages {{{

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

(eval-when-compile
  (require 'use-package))
(require 'diminish) ; if you use :diminish
(require 'bind-key) ; if you use any :bind variant

(use-package wrap-region
  :config (wrap-region-mode t))

(use-package dashboard
  :config (dashboard-setup-startup-hook))

(use-package flx-ido ; fuzzy matching for ido
  :config
  (flx-ido-mode 1)
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil))

(use-package rainbow-delimiters
  :config (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package expand-region
  :bind (("C-' r"  . er/expand-region)
         ("C-' w"  . er/mark-word)
         ("C-' '"  . er/mark-inside-quotes)
         ("C-' \"" . er/mark-outside-quotes)
         ("C-' p"  . er/mark-inside-pairs)
         ("C-' P"  . er/mark-outside-pairs)
         ("C-' c"  . er/mark-comment)
         ("C-' t"  . er/mark-inner-tag)
         ("C-' T"  . er/mark-outer-tag)
         ("C-' f"  . er/mark-defun)))

(use-package multiple-cursors
  :bind (("C-c c" . mc/edit-lines)
         ("C-c >" . mc/mark-next-like-this)
         ("C-c <" . mc/mark-previous-like-this)
         ("C-c ?" . mc/mark-all-like-this))
  :config (add-to-list 'mc/cursor-specific-vars 'iy-go-to-char-start-pos))

(use-package visual-regexp
  :defer) ; prevent loading this package before visual-regexp-steroids!

(use-package visual-regexp-steroids
  :ensure pcre2el ; much faster than Python
  :demand ; load this package immediately, regardless of :bind
  :bind (("C-c r" . vr/replace)
         ("C-c q" . vr/query-replace)
         ("C-c m" . vr/mc-mark)
         ("C-M-r" . vr/isearch-backward)
         ("C-M-s" . vr/isearch-forward))
  :config (setq vr/engine 'pcre2el))

;; for more information on how to load visual-regexp-steroids with use-package,
;; see workaround by alamaison @ GitHub at the following link:
;; https://github.com/benma/visual-regexp-steroids.el/issues/16#issue-123951566

(use-package paredit
  :config
  (autoload 'enable-paredit-mode
    "paredit" "Turn on pseudo-structural editing of Lisp code." t)
  (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
  (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
  (add-hook 'scheme-mode-hook           #'enable-paredit-mode)

  ;; re-map M-r, overriden by paredit-raise-sexp
  :bind ("M-R" . move-to-window-line-top-bottom))

(use-package paredit-everywhere
  :ensure paredit
  :config (add-hook 'prog-mode-hook 'paredit-everywhere-mode))

(use-package origami
  :config
  (global-origami-mode t)
  (setq-local origami-fold-style 'triple-braces)
  (defun custom-origami-toggle-node () ; (courtesy of /u/Eldrik @ reddit)
    (interactive)
    (save-excursion ; leave point where it is
      (goto-char (point-at-eol)) ; then go to the end of line
      (origami-toggle-node (current-buffer) (point)))) ; and try to fold

  :bind (("M-Z"   . custom-origami-toggle-node)
         ("C-M-z" . origami-toggle-all-nodes)))

(use-package framemove
  :config (setq framemove-hook-into-windmove t))

(use-package iy-go-to-char
  :bind (("M-m" . iy-go-to-char)
         ("M-M" . iy-go-to-char-backward)
         ("C-." . iy-go-to-char-continue)
         ("C-," . iy-go-to-char-continue-backward)))

(use-package magit
  :bind (("C-c g"   . magit-status)
         ("C-c C-g" . magit-diff-unstaged)
         ("C-c M-g" . magit-commit)))

(use-package fill-column-indicator
  :bind ("C-c i" . fci-mode))

(use-package avy
  :commands avy-isearch
  :init (global-set-key (kbd "M-'") nil) ; reset M-'
  :config (define-key isearch-mode-map (kbd "M-'") 'avy-isearch)
  :bind (("C-M-'" . abbrev-prefix-mark) ; re-bind default M-'
         ("M-' l" . avy-goto-line)
         ("M-' s" . avy-goto-char-timer)
         ("M-' w" . avy-goto-word-1)))

(use-package org
  :mode (("\\.org$" . org-mode))
  ;; :ensure org-plus-contrib
  :config
  (define-key org-mode-map (kbd "<C-M-return>") 'smart-open-line)
  (define-key org-mode-map (kbd "C-'") nil)
  ;; make windmove work in org-mode
  (add-hook 'org-shiftup-final-hook 'windmove-up)
  (add-hook 'org-shiftleft-final-hook 'windmove-left)
  (add-hook 'org-shiftdown-final-hook 'windmove-down)
  (add-hook 'org-shiftright-final-hook 'windmove-right))

(use-package helm
  :commands helm-command-prefix
  :bind (("M-x"     . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x C-b" . helm-buffers-list))
  :init
  (global-set-key (kbd "C-c C-h") 'helm-command-prefix)
  (global-unset-key (kbd "C-x c"))
  (require 'helm-config)
  (helm-mode 1)
  :config
  (helm-autoresize-mode 1)
  (setq helm-mode-fuzzy-match t
        helm-completion-in-region-fuzzy-match t ; "fuzzy" matching
        helm-split-window-in-side-p           t ; helm inside current window
        helm-autoresize-max-height           40
        helm-autoresize-min-height           0))

(use-package relative-line-numbers
  :config
  (defun relative-abs-line-numbers-format (offset)
    "Custom format function for `relative-line-numbers' that
    returns the absolute line number if the offset is zero (point
    is on the current line) and the relative number otherwise.

    Furthermore, the function adds padding as well as
    a separating line between the line numbers and the buffer."

    (concat (format "%4d " (if (= 0 offset)
                                            (line-number-at-pos)
                             (abs offset)))
            "\u2502"))
  (setq relative-line-numbers-format 'relative-abs-line-numbers-format)

  (defun toggle-line-numbers (&optional arg)
    "Toggles `relative-line-numbers-mode' and, as an added bonus,
    also the left fringe. The old fringe is saved in a variable
    and restored when line numbers are toggled off.

    I like to disable the left fringe to create an illusion of
    the hl-line continuing through the current line number. This,
    of course, requires that the current line number background
    is configured to be the same as the hl-line background. The
    function makes this happen as well.

    I only wrote this complicated function because
    `relative-line-numbers' provides no hooks.

    To force on, use C-u or provide `t' as an argument. To force
    off, use C-u C-u or provide `-1' as an argument."

    (interactive "p")
    (require 'cl-lib)

    (unless (boundp 'line-numbers-on)
      (setq line-numbers-on
            (if relative-line-numbers-mode t nil)))

    (set-face-background 'relative-line-numbers-current-line
                         (face-attribute 'hl-line :background))

    (cl-flet ((on (lambda ()
                    (setq old-fringe fringe-mode) ;; save old fringe
                    (if fringe-mode
                        (let ((right-fringe (cdr fringe-mode)))
                          (fringe-mode (cons 0 right-fringe)))
                      (fringe-mode '(0 . 8)))
                    (relative-line-numbers-mode)
                    (setq line-numbers-on t)))
              (off (lambda ()
                     (fringe-mode old-fringe) ;; reset to old fringe
                     (setq line-numbers-on nil)
                     (relative-line-numbers--off))))
      (if (or (eq arg 4) (eq arg t))
          (unless line-numbers-on (on)) ;; C-u -> on
        (if (or (eq arg 16) (eq arg -1))
            (if line-numbers-on (off)) ;; C-u C-u -> off
          (if line-numbers-on ;; no prefix -> toggle
              (off)
            (on))))))

  (add-hook 'prog-mode-hook '(lambda () (toggle-line-numbers t)))

  :bind ("C-c l" . toggle-line-numbers))

;; }}}

;; 2. Functions {{{

;; Set color scheme according to daylight

(defun daylight-sets-color ()
  "Sets a light theme for day and a dark theme for night.
  Depends on the script `sun' being found in path."

  (interactive)
  (let ((time (string-to-number (format-time-string "%H.%M"))))
        (if (string-match "not found" (shell-command-to-string "which sun"))
            (if (and (> time 6.00) (< time 18.00)) ; default if `sun' not found
                (load-theme light-theme t)
              (load-theme dark-theme t))
          (let ((sunrise
                 (string-to-number (shell-command-to-string "sun _rise")))
                (sunset
                 (string-to-number (shell-command-to-string "sun _set"))))
            (if (and (> time sunrise) (< time sunset))
                (load-theme light-theme t)
              (load-theme dark-theme t))))))

;; Jump to next fold

(defun traverse-folds (times &optional beginning)
  "Traverses through folds as many times as ordered by argument.
  A negative argument makes it traverse backwards."

  (unless beginning (setq beginning (point)))
  (if (> times 0)
      (progn
        (move-end-of-line nil)
        (fset 'fun 'origami-forward-fold))
    (progn
      (move-beginning-of-line nil)
      (fset 'fun 'origami-previous-fold)))
  (dotimes (i (abs times))
    (condition-case err
        (fun (current-buffer) (point))
      (error (message "Fold not found."))))
  (set-mark beginning)
  (deactivate-mark))

(defun next-fold (times)
  "Jumps to the beginning of the next fold (or previous, on
  negative argument)."

  (interactive "P")
  (unless times (setq times 1))
  (traverse-folds times))

(defun previous-fold (times)
  "Jumps to the beginning of the previous fold, as many times as
  ordered by argument."

  (interactive "P")
  (unless times (setq times 1))
  (next-fold (* times -1)))

(defun goto-fold (number)
  "Jumps to fold # (provided by argument) in file."

  (interactive "P")
  (unless number (setq number
                       (string-to-number (read-string "Jump to fold: "))))
  (setq beginning (point))
  (if (equal number 0) (setq number 1))
  (if (> number 0)
      (goto-char (point-min))
    (goto-char (point-max)))
  (traverse-folds number beginning))

;; Execute shell commands on parent shell (or any other tty)

(defun tty-shell-command (command &optional terminal &optional return-nil)
  "Executes a command on terminal (default: parent tty of frame).
  Note that it only works in Emacs frames attached to using
  `emacsclient -t'."

  (unless terminal (setq terminal (get-device-terminal nil))) ; tty of frame
  (let ((tty (terminal-name terminal)))
    (progn (setq output (shell-command (concat
                                        command
                                        " >"
                                        tty
                                        " 2>&1")))
      (if return-nil nil output))))

(defun tty-set-name (name &optional terminal)
  "Sets the title of the tty in which the current frame is
  open (or the tty provided by argument)."

  (tty-shell-command (concat
                      "echo -ne \"\033]0;"
                      name
                      "\007\"")
                     terminal) t) ; return-nil = t -> return nil no matter what

;; Dynamic settings for light/dark themes

(defun dynamic-load-theme (theme &optional rest ...)
  (if (and (fboundp 'light-theme-do) (equal theme 'solarized-light))
      (light-theme-do))
  (if (and (fboundp 'dark-theme-do) (equal theme 'gruvbox))
      (dark-theme-do)))

;; Custom Helm buffers

;; (defvar my/helm-source-spotify
;;   '((name . "Spotify")
;;     (:candidates "Song 1" "Song 2")))

;; (defun my/helm-spotify-remote ()
;;   (interactive)
;;   (helm :sources '(my/helm-source-spotify)
;;         :buffer "*helm-spotify-remote*"))

;; Various functions

(defun smart-open-line () ; (courtesy of Emacs Redux)
  "Insert an empty line after the current line.
  Position the cursor at beginning, according to current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))
(defun smart-open-line-above ()
  "Insert an empty line above the current line.
  Position the cursor at beginning, according to current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(defun comment-dwim-line (&optional arg) ; (courtesy of Jason Viers @ SE)
  "Replacement for the comment-dwim command.
  If no region is selected and current line is not blank and we
  are not at the end of the line, then comment current line.
  Replaces default behaviour of comment-dwim, when it inserts
  comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position)
                                   (line-end-position))
    (comment-dwim arg)))

(defun mark-line ()
  "Marks the current line."
  (interactive)
  (move-beginning-of-line nil)
  (push-mark)
  (setq mark-active t)
  (move-end-of-line nil)
  (forward-char))

(defun copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring.
      Ease of use features:
      - Move to start of next line.
      - Appends the copy on sequential calls.
      - Use newline as last char even on the last line of the buffer.
      - If region is active, copy its lines."
  (interactive "p")
  (let ((beg (line-beginning-position))
        (end (line-end-position arg)))
    (when mark-active
      (if (> (point) (mark))
          (setq beg
                (save-excursion (goto-char (mark)) (line-beginning-position)))
        (setq end
              (save-excursion (goto-char (mark)) (line-end-position)))))
    (if (eq last-command 'copy-line)
        (kill-append (buffer-substring beg end) (< end beg))
      (kill-ring-save beg end)))
  (kill-append "\n" nil)
  (beginning-of-line (or (and arg (1+ arg)) 2))
  (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))

(defun smarter-move-beginning-of-line (arg) ; (cy/o Emacs Redux)
  "Move point back to indentation of beginning of line.
  Move point to the first non-whitespace character on this line.
  If point is already there, move to the beginning of the line.
  Effectively toggle between the first non-whitespace character
  and the beginning of the line.
  If ARG is not nil or 1, move forward ARG - 1 lines first. If
  point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))
  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))
  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; }}}

;; 3. Preferences {{{

(server-start) ; use emacs as a server

;; Directories
(setq custom-file (concat user-emacs-directory "custom.el"))

(setq emacs-state-directory (concat user-emacs-directory "state/"))
(setq save-place-file (concat emacs-state-directory "save-place"))
(setq recentf-save-file (concat emacs-state-directory "recentf"))
(setq ido-save-directory-list-file (concat emacs-state-directory "ido.last"))
(setq backup-directory-alist
      `((".*" . ,(concat emacs-state-directory "saves"))))

;; Shebang mode detection
(add-to-list 'interpreter-mode-alist
             '("python3" . python-mode))

;; GUI
(add-to-list 'default-frame-alist
             '(font . "Fira Mono Medium-10"))

;; Themes

(setq light-theme 'solarized-light)
(setq dark-theme 'gruvbox)

(defun light-theme-do ()
  (setq fci-rule-color "#cccccc"))

(defun dark-theme-do ()
  (setq fci-rule-color "#333333"))

;; - Disable previous theme when enabling new theme
(add-hook 'after-init-hook
          (lambda () (defadvice load-theme
                         (before theme-dont-propagate activate)
                       (mapcar #'disable-theme custom-enabled-themes))))

;; - Dynamic settings for light/dark themes
(advice-add 'load-theme :after #'dynamic-load-theme)

;; - Set theme according to daylight
(daylight-sets-color)

;; Spelling
(require 'ispell)
(add-to-list 'ispell-dictionary-alist
             '("swedish-hunspell"
               "[[:alpha:]]"
               "[^[:alpha:]]"
               "[']"
               t
               ("-d" "sv_SE")
               nil
               utf-8))

(add-to-list 'ispell-dictionary-alist
             '("english-hunspell"
               "[[:alpha:]]"
               "[^[:alpha:]]"
               "[']"
               t
               ("-d" "en_US")
               nil
               utf-8))
(setq ispell-program-name "hunspell"
      ispell-dictionary   "swedish-hunspell")

;; Enabling disabled commands
(defadvice en/disable-command (around put-in-custom-file activate)
  "Put declarations in `custom-file'."
  (let ((user-init-file (concat user-emacs-directory ".commands")))
    ad-do-it))
(load-file (concat user-emacs-directory ".commands"))

;; Change cursor to block on suspend, and back to ibeam on resume
(add-hook 'suspend-tty-functions
          (lambda (terminal)
            (tty-shell-command "echo -ne \"\e[2 q\"" terminal)))
(add-hook 'resume-tty-functions
          (lambda (terminal)
            (tty-shell-command "echo -ne \"\e[6 q\"" terminal)))

;; }}}

;; 4. Keybindings {{{

(windmove-default-keybindings)

(global-set-key (kbd "M-<f1>") 'menu-bar-mode)

(global-set-key (kbd "C-c C-z") 'goto-fold)
(global-set-key (kbd "C-c C-n") 'next-fold)
(global-set-key (kbd "C-c C-p") 'previous-fold)

(global-set-key (kbd "M-n") (lambda (n) (interactive "p") (scroll-up n)))
(global-set-key (kbd "M-p") (lambda (n) (interactive "p") (scroll-down n)))
(global-set-key (kbd "M-RET") 'smart-open-line)
(global-set-key (kbd "M-o") 'smart-open-line-above)
(global-set-key (kbd "C-;") 'comment-dwim-line)
(global-set-key (kbd "C-c C-k") 'copy-line)
(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)

;; }}}

;; 5. Mode configuration {{{

(electric-pair-mode 1) ; auto-insert matching pairs
(menu-bar-mode -1)     ; disable menu bar
(global-hl-line-mode)  ; highlight current line
(save-place-mode 1)    ; save cursor position
(xterm-mouse-mode t)   ; use mouse (somewhat) in terminal
(tool-bar-mode -1)     ; disable gui toolbar

;; auto-fill-mode
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; python-mode
(defun shell-compile () ; (courtesy of djangoliv @ stack interchange)
  (interactive)
  (shell-command (concat "python " (buffer-file-name)))
  (if (<= (* 2 (window-height)) (frame-height))
      (enlarge-window 20)
    (/ (frame-height) 2)))
(add-hook 'python-mode-hook
          '(lambda ()
             (define-key python-mode-map (kbd "C-c C-c") 'shell-compile)))


;; (La)TeX-mode
(add-hook 'TeX-mode-hook '(lambda () (setq TeX-command-default "latexmk")))
(defun my-latex-setup (&optional args)
  (defun start-update-viewer ()
    "Starts/updates PDF viewer."
    (interactive)
    (if (string-match "no process found"
                      (shell-command-to-string "killall -HUP mupdf-x11"))
        (start-process-shell-command
         "mupdf"          ; process name
         "mupdf"          ; process buffer
         (concat "mupdf " ; shell command
                 (expand-file-name
                  (concat "output/"
                          (file-name-base (buffer-file-name))
                          ".pdf"))))))
  (define-key LaTeX-mode-map (kbd "C-c C-u") 'start-update-viewer)

  (defun save-run ()
    "Saves the document and processes it."
    (interactive)
    (save-buffer)
    (TeX-command-run-all nil))

  (defun latex-word-count () ; (courtesy of Nicholas Riley @ SE)
    (interactive)
    (let* ((this-file (buffer-file-name))
           (word-count
            (with-output-to-string
              (with-current-buffer standard-output
                (call-process "texcount" nil t nil "-brief" this-file)))))
      (string-match "\n$" word-count)
      (message (replace-match "" nil nil word-count))))
  (define-key LaTeX-mode-map (kbd "C-c w") 'latex-word-count)

  (defun latex-write-word-count ()
    "Writes the word count to count.txt (if it exists)."
    (interactive)
    (shell-command (concat "texcount -brief "
                    (shell-quote-argument buffer-file-name)
                    " | sed -e 's/+.*//' > count.txt; cat count.txt")))
  (define-key LaTeX-mode-map (kbd "C-c M-w") 'latex-write-word-count))
(add-hook 'LaTeX-mode-hook 'my-latex-setup t)

;; }}}

;; 6. Custom modes {{{

;; Swedish letters

;; Based on work by Moritz Ulrich <ulrich.moritz@googlemail.com>
;; Published under GNU General Public License
(define-minor-mode swedish-mode
  "A mode for conveniently using Swedish letters in Emacs.
  Note that this rebinds several important Emacs bindings,
  including ones used by xterm-mouse-mode. To use these bindings
  again, be sure to toggle the submode off."
  nil
  :lighter " åäö"
  :keymap '(("\M-["  . (lambda () (interactive) (insert ?å)))
            ("\M-'"  . (lambda () (interactive) (insert ?ä)))
            ("\M-;"  . (lambda () (interactive) (insert ?ö)))
            ("\M-{"  . (lambda () (interactive) (insert ?Å)))
            ("\M-\"" . (lambda () (interactive) (insert ?Ä)))
            ("\M-:"  . (lambda () (interactive) (insert ?Ö)))))
(provide 'swedish-mode)

;; }}}

;; 7. Customize {{{

(load custom-file)

;; }}}
