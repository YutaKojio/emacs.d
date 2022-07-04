;; -*- Mode: Emacs-Lisp; Coding: utf-8 -*-
;;; init.el --- Minimum init.el for general use.

;; Author: Tatsuya Ishikawa <ishikawa@jsk.imi.i.u-tokyo.ac.jp>

(defvar bootstrap-version)
(defvar straight-check-for-modifications '(check-on-save find-when-checking))
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(add-to-list 'load-path (locate-user-emacs-file "site-lisp"))

(eval-when-compile
  (message "Byte compile site-lisp")
  (byte-recompile-directory (locate-user-emacs-file "site-lisp") 0)
  )

;; Byte compile when opening emacs if init.el is newer than init.elc
(add-hook 'after-init-hook
          '(lambda ()
             (let* ((el (expand-file-name "init.el" user-emacs-directory))
                    (elc (concat el "c")))
               (when (file-newer-than-file-p el elc)
                 (byte-compile-file el)))))

(straight-use-package 'use-package)
;; use-package will use straight.el to automatically install missing packages
(setq straight-use-package-by-default t)
(require 'bind-key)

(use-package init-loader
  :init
  (init-loader-load (expand-file-name "init" user-emacs-directory))
  :custom
  (init-loader-byte-compile t)
  (init-loader-show-log-after-init 'error-only))

;; Change color theme
(add-hook 'tty-setup-hook '(lambda () (set-terminal-parameter nil 'background-mode 'dark)))

;; Hidden tool bar
(tool-bar-mode -1)
;; Hidden menu bar
(menu-bar-mode -1)
;; Auto reload when file is changed
(global-auto-revert-mode 1)
;; Show line and column number
(line-number-mode t)
(column-number-mode t)
;; Ask whether to insert newline at final line
(setq require-final-newline nil)

;; Set buffer that can not be killed.
(with-current-buffer "*scratch*"
  (emacs-lock-mode 'kill))
(with-current-buffer "*Messages*"
  (emacs-lock-mode 'kill))

;; Share clipboard
(use-package xclip
  :config
  (when (eq 0 (shell-command "type xclip"))
    (xclip-mode 1)))

;; Don't distinguish upper/lower cases when search
(setq case-fold-search t)
;; Don't distinguish upper/lower cases when incremental search
(setq isearch-case-fold-search t)
;; Don't distinguish upper/lower cases when complete buffer name
(setq read-buffer-completion-ignore-case t)
;; Don't distinguish upper/lower cases when complete file name
(setq read-file-name-completion-ignore-case t)

;;; Setting of indent
(setq-default tab-width 4)
;; Prohibit using use hard tab.
(setq-default indent-tabs-mode nil)
;; Auto indent
(electric-indent-mode t)

;; don't make backup file such as (*.~)
(setq make-backup-files nil)

;; ignore start message
(setq inhibit-startup-message t)

;; Turn off alarms completely
(setq ring-bell-function 'ignore)

;;; Delete endline whitespace with saving files
(defvar delete-trailing-whitespece-before-save nil)
(defun my-delete-trailing-whitespace ()
  (if delete-trailing-whitespece-before-save
      (delete-trailing-whitespace)))
(add-hook 'before-save-hook 'my-delete-trailing-whitespace)
;; Disable delete-trailing-whitespace at some modes below
(add-hook 'markdown-mode-hook
          '(lambda ()
             (set (make-local-variable 'delete-trailing-whitespece-before-save) nil)))

;; Show paren
(show-paren-mode t)
(setq show-paren-delay 0)

;; Follow the symlink and visit the real file
(setq vc-follow-symlinks t)

;;; add color tab, zenkaku-space, hankaku-space
(defface my-tab-face '((t (:background "orange"))) nil)
(defface my-zenkaku-face '((t (:background "gray10"))) nil)
(defface my-hankaku-face '((t (:background "SteelBlue1" :underline t))) nil)
(defvar my-tab-face 'my-tab-face)
(defvar my-zenkaku-face 'my-zenkaku-face)
(defvar my-hankaku-face 'my-hankaku-face)

(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("\t" 0 my-tab-face append)
     ("　" 0 my-zenkaku-face append)
     ;; ("[ \t]+$" 0 my-hankaku-face append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

;;; Basic keybindings
(bind-key* "C-j" 'newline-and-indent (not (eq major-mode 'lisp-interaction-mode)))
(define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))
(bind-key* "\M-g" 'goto-line)
(bind-key* "\C-xL" 'goto-line)
(bind-key* "\C-xR" 'revert-buffer)
(bind-key* "C-x k" (lambda () (interactive) (kill-buffer (buffer-name))))

;;; Rectangle mark
;; C-x Space ( M-x cua-set-rectangle-mark ) 矩形モード開始
;; キーバインド | 説明
;; | M-b          | 矩形をスペースで埋める
;; | M-f          | 矩形を入力された1文字で埋める
;; | M-i          | 矩形の各行の数値をインクリメントする
;; | M-k          | 矩形をキルする
;; | M-n          | 矩形の各行にインクリメントされた数値をフォーマットして挿入する
;; | M-r          | 矩形を置換する
;; | M-t          | 矩形を入力された文字列で埋める
;; | M-|          | 矩形を入力としてシェルコマンドを実行する。引数が指定されている場合はシェルコマンドの結果が矩形に埋まる
;; | M-/          | 矩形の正規表現にマッチする行をハイライト
(use-package cua-base
  :init (cua-mode t)
  :bind ("C-x SPC" . cua-set-rectangle-mark)
  :config
  (setq cua-enable-cua-keys nil))

;; Scroll line by line
(setq scroll-conservatively 1)
;;; Scroll up and down by M-n and M-p
(defun scroll-up-in-place (n)
  (interactive "p")
  (previous-line n)
  (scroll-down n))
(defun scroll-down-in-place (n)
  (interactive "p")
  (next-line n)
  (scroll-up n))
(bind-key "M-n" 'scroll-down-in-place)
(bind-key "M-p" 'scroll-up-in-place)

;; Completion using C-o
(bind-key* "\C-o" 'dabbrev-expand)

;;; M-qで括弧間を移動
(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        )
  )
(bind-key* "M-q" 'match-paren)

;;; For folding
;; http://d.hatena.ne.jp/yutoichinohe/20121119/1353321674
(dolist (mode-hook '(scheme-mode-hook
                     emacs-lisp-mode-hook
                     lisp-mode-hook
                     python-mode-hook
                     ruby-mode-hook))
  (add-hook mode-hook '(lambda () (hs-minor-mode t))))
(bind-key "C-c ;" 'hs-toggle-hiding)

;;; anzu
(use-package anzu
  :init
  (global-anzu-mode +1)
  (set-face-attribute 'anzu-mode-line nil
                      :foreground "#0000ff" :background "orange" :weight 'bold)
  (bind-key* "M-r" 'anzu-query-replace (not (eq major-mode 'shell-mode)))
  :custom
  (anzu-mode-lighter "")
  (anzu-deactivate-region t)
  (anzu-search-threshold 1000)
  (anzu-replace-to-string-separator " => "))

;;; dtrt-indent
(use-package dtrt-indent
  :init
  (dtrt-indent-global-mode t)
  :custom
  (dtrt-indent-min-quality 50.0))

;;; Keybindings
;; (use-package which-key
;;   :config
;;   (which-key-setup-side-window-right-bottom)
;;   (which-key-mode t))

;;; Git
(use-package git-modes
  :defer t
  :config
  (add-hook 'gitconfig-mode-hook '(lambda () (setq indent-tabs-mode nil))))

(use-package git-gutter
  :init
  ;; If you enable global minor mode
  (global-git-gutter-mode t)
  ;; If you would like to use git-gutter.el and linum-mode
  ;; (git-gutter:linum-setup)
  ;; If you enable git-gutter-mode for some modes
  ;; (add-hook 'ruby-mode-hook 'git-gutter-mode)
  :config
  (set-face-background 'git-gutter:modified "purple") ;; background color
  (set-face-foreground 'git-gutter:added "green")
  (set-face-foreground 'git-gutter:deleted "red")
  (set-face-foreground 'git-gutter:separator "blue")
  :bind
  ("C-x g" . git-gutter-mode)
  ("C-x v =" . git-gutter:popup-hunk)
  ("C-x p" . git-gutter:previous-hunk)
  ("C-x n" . git-gutter:next-hunk)
  ("C-x v r" . git-gutter:revert-hunk)
  ("C-x v s" . git-gutter:stage-hunk)
  ("C-x v SPC" . git-gutter:mark-hunk)
  :custom
  (git-gutter:modified-sign " ")
  (git-gutter:added-sign "+")
  (git-gutter:deleted-sign "-")
  (git-gutter:separator-sign "|")
  (git-gutter:always-show-separator t))

;;; rainbow-mode
(use-package rainbow-mode
  :init
  (dolist (mode-hook '(css-mode-hook  web-mode-hook
                       html-mode-hook vrml-mode-hook
                       emacs-lisp-mode-hook qml-mode-hook))
    (add-hook mode-hook 'rainbow-mode)))

;;; Setting for minor modes

(dolist (mode-hook '(python-mode-hook))
  ;; (add-hook mode-hook '(lambda () (electric-indent-local-mode -1)))) ;; for emacs 24.4 or above
  (add-hook mode-hook '(lambda () (set (make-local-variable 'electric-indent-mode) nil))))

;; shell mode
(defvar shell-command-option "-c")
(use-package bash-completion
  :hook shell-mode
  :config
  (add-hook 'shell-dynamic-complete-functions
            'bash-completion-dynamic-complete))

;; vrml mode
(use-package vrml-mode
  :straight nil
  :mode "\\.wrl\\'")

;; yaml mode
(use-package yaml-mode
  :mode ("\\.rosinstall\\'"
         "\\.cnoid\\'" ;; Choreonoid project file
         "\\.body\\'"  ;; Choreonoid body file
         ))

(use-package cmake-mode
  :defer t)

;; Euslisp mode
(use-package euslisp-mode
  :straight nil
  :mode "\\.l\\'")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(completions-first-difference ((t (:inherit bold :foreground "color-164"))))
 '(diff-refine-added ((t (:inherit diff-refine-changed :background "color-22"))))
 '(font-lock-warning-face ((t (:foreground "#ff3700"))))
 '(query-replace ((t (:inherit isearch :background "color-40")))))

;; line-mode                                                                                           
;; (global-linum-mode t)
(setq linum-format "%4d ")

;; melpa
(when (require 'package nil t)
  (add-to-list 'package-archives
               '("melpa-stable" . "https://stable.melpa.org/packages/"))
  (package-initialize))

;; smart-jump
(use-package smart-jump
  :ensure t
  :bind (("M-." . smart-jump-go)
         ("M-," . smart-jump-back)
         ("M-?" . smart-jump-references)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(defun window-resizer ()
  "Control window size and position."
  (interactive)
  (let ((window-obj (selected-window))
        (current-width (window-width))
        (current-height (window-height))
        (dx (if (= (nth 0 (window-edges)) 0) 1
              -1))
        (dy (if (= (nth 1 (window-edges)) 0) 1
              -1))
        action c)
    (catch 'end-flag
      (while t
        (setq action
              (read-key-sequence-vector (format "size[%dx%d]"
                                                (window-width)
                                                (window-height))))
        (setq c (aref action 0))
        (cond ((= c ?l)
               (enlarge-window-horizontally dx))
              ((= c ?h)
               (shrink-window-horizontally dx))
              ((= c ?j)
               (enlarge-window dy))
              ((= c ?k)
               (shrink-window dy))
              ;; otherwise
              (t
               (let ((last-command-char (aref action 0))
                     (command (key-binding action)))
                 (when command
                   (call-interactively command)))
               (message "Quit")
               (throw 'end-flag t)))))))
(global-set-key "\C-x\w" 'window-resizer)
(setq split-width-threshold nil)
