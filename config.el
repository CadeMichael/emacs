;;; main-config --- Cade's Emacs Config -*- lexical-binding: t; -*-
;;; Commentary:
;; Should work with macos and linux.
;; Simple and non exhaustive
;;; Code:

;;; base config

;; emacs configuration
(use-package emacs
  :straight nil
  :preface
  (defun open-config-file ()
    "Open this file ie 'config.el'."
    (interactive)
    (find-file (expand-file-name "config.el" user-emacs-directory)))
  (defun open-note-file ()
    "Open a note file."
    (interactive)
    (find-file "~/zkast"))
  :custom
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  :config
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (setopt use-short-answers t)
  (setq visible-bell t)
  (setq inhibit-splash-screen t)
  (setq warning-minimum-level :error)   ; only warn on errors
  (setq                                 ; no warnings
   native-comp-async-report-warnings-errors nil)
  (setq make-backup-files nil)		; no backup files
  (add-to-list 'default-frame-alist
	       '(font . "0xProto Nerd Font-16"))
  (add-hook				; line nums for code
   'prog-mode-hook 'display-line-numbers-mode)
  (setq python-indent-guess-indent-offset-verbose nil))

;; built in project management
(use-package project
  :straight nil
  :preface
  ;; find cmake projects
  (defun project-find-cmake (dir)
    (when-let ((root (locate-dominating-file dir "CMakeLists.txt")))
      (cons 'cmake-lists root)))
  (cl-defmethod project-root ((project (head cmake-lists)))
    (cdr project))
  ;; find uv projects
  (defun project-find-uv (dir)
    (when-let ((root (locate-dominating-file dir "pyproject.toml")))
      (cons 'uv-lists root)))
  (cl-defmethod project-root ((project (head uv-lists)))
    (cdr project))
  ;; find projects w/ a README
  (defun project-find-README (dir)
    (when-let ((root (locate-dominating-file dir "README.md")))
      (cons 'README-lists root)))
  (cl-defmethod project-root ((project (head README-lists)))
    (cdr project))
  :config
  (add-hook 'project-find-functions 'project-find-cmake)
  (add-hook 'project-find-functions 'project-find-uv)
  (add-hook 'project-find-functions 'project-find-README))

;; set up shell paths
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x pgtk))
    (exec-path-from-shell-initialize)))

;; undo
(use-package undo-fu)

;; vim bindings
(use-package evil
  :init
  (setq evil-want-keybinding nil)  ; needed for evil-collection
  (setq evil-want-C-u-scroll t)    ; allow scroll up with 'C-u'
  (setq evil-want-C-d-scroll t)    ; allow scroll down with 'C-d'
  (setq evil-undo-system 'undo-fu) ; undo system for 'C-r'
  :config
  (evil-mode 1)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

;; better evil support accross modes
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; remapping
(use-package general
  :config
  (general-evil-setup)
  ;; evil maps
  (general-nmap
    "U" 'evil-redo)
  (general-nmap 'eat-mode-map
    "q" 'quit-window)
  ;; global keybindings
  (general-create-definer global/leader-keys
    :defer t
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")
  (global/leader-keys
    ;; SPC +
    "SPC" '(vterm-toggle :wk "vterm toggle")
    "o c" '(open-config-file :wk "open config file")
    "c" '(delete-window :wk "delete window")
    "k" '(kill-buffer-and-window :wk "kill buffer and window")
    "h l" '(hl-line-mode :wk "hl line mode")
    "W" '(toggle-truncate-lines :wk "toggle truncate lines")
    ";" '(comment-line :wk "comment line")
    "/" '(rg-literal :wk "rg literal")
    "." '(find-file :wk "find file")
    "<" '((lambda () (interactive)
	    (call-interactively #'find-file-other-window)
	    (evil-window-move-far-left))
	  :wk "find file other window")
    ">" '((lambda () (interactive)
	    (call-interactively #'find-file-other-window)
	    (evil-window-move-far-right))
	  :wk "find file other window")
    "," '(consult-buffer :wk "find buffer")
    ":" '(execute-extended-command :wk "execute extended command") ; M-x
    "!" '(shell-command :wk "shell command")
    "&" '(async-shell-command :wk "async shell command")
    "x" '(execute-extended-command :wk "M-x")
    "p s" '(project-switch-project :wk "project switch")
    "p k" '(project-kill-buffers :wk "project kill buffers")
    "p f" '(project-find-file :wk "project find file")
    "p F" '(project-forget-project :wk "project forget")
    "p R" '(project-remember-projects-under :wk "project remember projects under")
    "p !" '(project-shell-command :wk "project shell command")))

;; keybinding helper
(use-package which-key
  :config
  (which-key-mode 1))

;; requirement for completion engines
(use-package compat)

;; completion
(use-package vertico
  :after compat
  :custom
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t)  ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; fancy completion
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; use vertico settings
  (completion-pcm-leading-wildcard t))

;; for ripgrep usage
;; in rg menu
;; - "t" -> rerun search, change literal
;; - "r" -> rerun search, change regexp
(use-package transient)

(use-package rg :after transient)

;; find with previews
(use-package consult
  :after vertico
  :config
  (setq consult-preview-key "C-.")
  :bind
  ("C-x b" . consult-buffer)
  ("C-x f" . consult-find))

;; theme
(use-package modus-themes
  :config
  (modus-themes-load-theme 'modus-vivendi-tinted))

;; embedded terminal
(use-package vterm
  :after (evil-collection general))

(use-package vterm-toggle
  :after vterm)

;; tree sitter
(use-package treesit
  :straight nil
  :mode
  (("\\.tsx\\'" . tsx-ts-mode)
   ("\\.js\\'"  . typescript-ts-mode)
   ("\\.mjs\\'" . typescript-ts-mode)
   ("\\.mts\\'" . typescript-ts-mode)
   ("\\.cjs\\'" . typescript-ts-mode)
   ("\\.ts\\'"  . typescript-ts-mode))
  :config
  (setq treesit-font-lock-level 4) ; maximum highlighting
  (setq major-mode-remap-alist
	'((python-mode . python-ts-mode)
	  (go-mode . go-ts-mode)
	  (c-mode . c-ts-mode))))

;; folding
(use-package treesit-fold
  :straight (:host github :repo "emacs-tree-sitter/treesit-fold")
  :hook ((typescript-ts-mode . treesit-fold-mode)
	 (python-ts-mode . treesit-fold-mode)
	 (markdown-ts-mode . treesit-fold-mode)
	 (c-ts-mode . treesit-fold-mode)))

;;; language configs

;; parens coloring
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

;; parenthesis wrangling
					; `M-r' raise sexp
					; `M-s' splice sexp
					; `M-S' split sexp
(use-package paredit
  :commands paredit-mode
  :hook
  (clojure-ts-mode . paredit-mode)
  (emacs-lisp-mode . paredit-mode))

;; better evil integration
(use-package enhanced-evil-paredit
  :commands enhanced-evil-paredit-mode
  :hook (paredit-mode . enhanced-evil-paredit-mode))

;; completion
(use-package company
  :hook
  (prog-mode . company-mode))

;; snippets
(use-package yasnippet
  :config
  (setq yas-snippet-dirs
	'("~/.config/emacs/snippets"))
  (yas-reload-all)
  (add-hook 'prog-mode-hook #'yas-minor-mode))

;; lsp
(use-package eglot
  :straight nil
  :config
  (add-to-list 'eglot-ignored-server-capabilites :hoverProvider)
  (add-to-list 'eglot-server-programs
	       '(nim-mode "nimlsp")))

;; need to be in insert mode to quit
(use-package eldoc-box
  :after eglot
  :config
  (general-define-key
   :states 'normal
   :keymaps 'eglot-mode-map
   "K" 'eldoc-box-help-at-point))

;; linting
(use-package flycheck
  :hook
  (prog-mode . flycheck-mode))

;; git
(use-package magit
  :after (evil-collection transient))

;; docker
(use-package docker
  :custom
  (docker-command "podman")
  (docker-compose-command "podman-compose")
  (docker-container-tramp-method "docker")
  :bind ("C-c d" . docker))

;; markdown
(use-package markdown-ts-mode
  :mode ("\\.md\\'" . markdown-ts-mode))

;; clojure
(use-package clojure-ts-mode)

(use-package cider
  :config
  (general-define-key
   :states '(normal visual)
   :keymaps 'clojure-ts-mode-map
   :prefix "SPC"
   "n" '(cider-ns-map :wk "cider ns map")))

;; python
(use-package python
  :straight nil
  :preface
  (defvar python-last-buffer nil
    "The last python buffer to call the repl.")
  (defun +python/goto-python-buffer ()
    "Switch to active python REPL."
    (interactive)
    (if (buffer-live-p (get-buffer python-last-buffer))
	(switch-to-buffer-other-window python-last-buffer)
      (message "python buffer deleted")))
  (defun +python/goto-repl ()
    "Switch to active python REPL."
    (interactive)
    (setq python-last-buffer (current-buffer))
    (python-shell-switch-to-shell))
  (defun +python/run-python ()
    "Start python process."
    (interactive)
    (setq python-last-buffer (current-buffer))
    (run-python))
  :bind
  (:map python-ts-mode-map
	([remap python-shell-switch-to-shell] . +python/goto-repl)
	([remap run-python] . +python/run-python)
	("C-c r" . python-shell-restart)
	:map inferior-python-mode-map
	("C-c r" . python-shell-restart)
	("C-c C-z" . +python/goto-python-buffer)))

;; nim
(use-package nim-mode)

;; odin
(use-package odin-mode
  :straight (:host github :repo "mattt-b/odin-mode"))

;; scheme
(use-package geiser-chez)

;; direnv
(use-package envrc
  :config
  (envrc-global-mode))

;;; config.el ends here
