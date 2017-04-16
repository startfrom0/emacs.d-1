; ==============================================================================
;                           init.el by John Ankarström
; ==============================================================================

; Packages {{{

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

; origami-mode

;; (global-set-key (kbd "M-Z") 'origami-mode)
(defun custom-origami-toggle-node () ; (courtesy of /u/Eldrik @ reddit)
  (interactive)
  (save-excursion ; leave point where it is
    (goto-char (point-at-eol)) ;; then go to the end of line
    (origami-toggle-node (current-buffer) (point)))) ; and try to fold
(add-hook 'origami-mode-hook
          (lambda ()
            (global-set-key (kbd "M-Z") 'custom-origami-toggle-node)
            (global-set-key (kbd "C-M-z") 'origami-toggle-all-nodes)
            (setq-local origami-fold-style 'triple-braces)))
(global-origami-mode t)

; auctex-latexmk
(require 'auctex-latexmk)
(auctex-latexmk-setup)

; }}}

; Preferences {{{

; (load-theme 'subatomic256 t)
(load-theme 'gruvbox t)
(setq-default fill-column 80)
;; (setq-default kill-whole-line t) ; C-k kills newline as well
(setq-default indent-tabs-mode nil) ; don't mix spaces and tabs
(setq-default tab-width 4) ; should this be on a per-language basis instead?
(server-start) ; use emacs as a server - edit new files using emacsclient
(setq-default column-number-mode t) ; display column along with line number
(setq-default indent-tabs-mode nil) ; don't use tabs
(setq sentence-end-double-space nil) ; don't use double-spacing

; Save ~ files to ~/.emacs.d/.saves instead of current directory
(setq backup-directory-alist `(("." . "~/.emacs.d/.saves")))

; Line numbers
(global-linum-mode)
(setq linum-format "%4d \u2502 ")

; Shebang mode detection
(add-to-list 'interpreter-mode-alist
             '("python3" . python-mode))

; Enabling disabled commands
(defadvice en/disable-command (around put-in-custom-file activate)
  "Put declarations in `custom-file'."
  (let ((user-init-file "/home/john/.emacs.d/.commands"))
    ad-do-it))

; Modes {{{

(xterm-mouse-mode t)
(electric-pair-mode 1) ; auto-insert matching pairs
(menu-bar-mode -1) ; disable menu bar
(global-hl-line-mode) ; highlight current line

; save-place (save cursor position in file)
(require 'saveplace)
(setq-default save-place t)

; ido-mode
(require 'ido)
(ido-mode t)

; python-mode
(defun shell-compile () ; (courtesy of djangoliv @ stack interchange)
  (interactive)
  (shell-command (concat "python " (buffer-file-name)))
  (if (<= (* 2 (window-height)) (frame-height))
      (enlarge-window 20)
    (/ (frame-height) 2)))
(add-hook 'python-mode-hook
          '(lambda ()
             (define-key python-mode-map (kbd "C-c C-c") 'shell-compile)))

; LaTeX-mode
(defun my-latex-setup ()
  (defun update-mupdf ()
    "Updates mupdf by sending a SIGHUP signal to it."
    (interactive)
    (shell-command "killall -HUP mupdf & echo 'Update signal sent.'"))
  (define-key LaTeX-mode-map (kbd "C-c C-u") 'update-mupdf)

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
(add-hook 'TeX-mode-hook '(lambda () (setq TeX-command-default "latexmk")))

; }}}

; }}}

; Custom keybindings {{{

; Quick window switching

(global-set-key (kbd "M-N") 'next-multiframe-window)
(global-set-key (kbd "M-P") 'previous-multiframe-window)

; C-e & C-y like in vi
(defun ctrl-e-in-vi (n)
 (interactive "p")
 (scroll-up n))
(defun ctrl-y-in-vi (n)
 (interactive "p")
 (scroll-down n))
(global-set-key (kbd "M-n") 'ctrl-e-in-vi)
(global-set-key (kbd "M-p") 'ctrl-y-in-vi)

; Open-line above and below (courtesy of Emacs Redux)

(defun smart-open-line ()
  "Insert an empty line after the current line.
Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun smart-open-line-above ()
  "Insert an empty line above the current line.
Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "M-o") 'smart-open-line)
(global-set-key (kbd "M-O") 'smart-open-line-above)

; Commenting

(defun comment-dwim-line (&optional arg) ; (courtesy of Jason Viers @ SE)
  "Replacement for the comment-dwim command.
  If no region is selected and current line is not blank and we are not at the end of the line,
  then comment current line.
  Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
(global-set-key "\M-;" 'comment-dwim-line)

; Mark line

(defun mark-line ()
  "Marks the current line."
  (interactive)
  (move-beginning-of-line nil)
  (push-mark)
  (setq mark-active t)
  (move-end-of-line nil)
  (forward-char))

(global-set-key (kbd "M-]") 'mark-line)

; Copy line

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
          (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
        (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
    (if (eq last-command 'copy-line)
        (kill-append (buffer-substring beg end) (< end beg))
      (kill-ring-save beg end)))
  (kill-append "\n" nil)
  (beginning-of-line (or (and arg (1+ arg)) 2))
  (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))
(global-set-key (kbd "C-c C-k") 'copy-line)

; }}}

; Custom modes {{{

; Swedish letters

; Based on work by Moritz Ulrich <ulrich.moritz@googlemail.com>
; Published under GNU General Public License
(define-minor-mode swedish-mode
  "A mode for conveniently using Swedish letters in Emacs"
  nil
  :lighter " åäö"
  :keymap '(("\M-[" . (lambda () (interactive) (insert ?å)))
            ("\M-'" . (lambda () (interactive) (insert ?ä)))
            ("\M-;" . (lambda () (interactive) (insert ?ö)))
            ("\M-{" . (lambda () (interactive) (insert ?Å)))
            ("\M-\"" . (lambda () (interactive) (insert ?Ä)))
            ("\M-:" . (lambda () (interactive) (insert ?Ö)))))
(provide 'swedish-mode)

; }}}
