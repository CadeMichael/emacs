;;; main-config --- Cade's Emacs Config -*- lexical-binding: t; -*-
;;; Commentary:
;; Should work with macos and linux.
;; Simple and non exhaustive
;;; Code:

;;; base config

;; compile angle
(setq load-prefer-newer t)

(use-package compile-angel
  :demand t
  :config
  (setq compile-angel-verbose t)
  (push "/init.el" compile-angel-excluded-files)
  (push "/early-init.el" compile-angel-excluded-files)
  (push "/config.el" compile-angel-excluded-files)
  (compile-angel-on-load-mode 1))

;; emacs configuration
(use-package emacs
  :straight nil
  :preface
  (defun open-config-file ()
    "Open this file ie 'config.el'."
    (interactive)
    (find-file (expand-file-name "config.el" user-emacs-directory)))
  (defun open-md-note-file ()
    "Open a note file."
    (interactive)
    (find-file "~/zkast"))
  :custom
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  :config
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (setq-default tab-width 4)
  (setopt use-short-answers t)
  (setq visible-bell t)
  (setq inhibit-splash-screen t)
  (setq warning-minimum-level :error)   ; only warn on errors
  (setq                                 ; no warnings
   native-comp-async-report-warnings-errors nil)
  (setq make-backup-files nil)			; no backup files
  (setq compile-command "just build")	; just easier compilation
  (add-to-list 'default-frame-alist
			   '(font . "0xProto Nerd Font-16"))
  (add-hook								; line highlighting for code
   'prog-mode-hook #'hl-line-mode)
  (add-hook								; line nums for code
   'prog-mode-hook #'display-line-numbers-mode)
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
  ;; find lakefile projects
  (defun project-find-lakefile (dir)
    (when-let ((root (locate-dominating-file dir "lakefile.toml")))
      (cons 'lakefile-lists root)))
  (cl-defmethod project-root ((project (head lakefile-lists)))
    (cdr project))
  ;; find uv projects
  (defun project-find-uv (dir)
    (when-let ((root (locate-dominating-file dir "pyproject.toml")))
      (cons 'uv-lists root)))
  (cl-defmethod project-root ((project (head uv-lists)))
    (cdr project))
  :config
  (add-hook 'project-find-functions #'project-find-cmake)
  (add-hook 'project-find-functions #'project-find-lakefile)
  (add-hook 'project-find-functions #'project-find-uv))
  

;; org
(use-package org
  :straight nil
  :config
  (setq org-log-done t) ; mark `DONE' tasks `CLOSED'
  (setq org-agenda-files (list (expand-file-name "org/" user-emacs-directory))))

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
  (setq evil-want-keybinding nil)  ; needed for `evil-collection'
  (setq evil-want-integration t)   ; needed for `evil-collection'
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

;; fixing evil maps
;;; repls
(use-package comint
  :straight nil
  :bind
  ("C-<return>" . comint-send-input))

;; remapping
(use-package general
  :config
  (general-evil-setup)
  ;; evil maps
  (general-nmap
    "U" 'evil-redo)
  ;; global keybindings
  (general-create-definer global/leader-keys
    :defer t
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")
  (global/leader-keys
    ;; SPC +
	;; terminal
    "SPC" '(ghostel :wk "ghostel")
	;; config
    "o c" '(open-config-file :wk "open config file")
	;; org
    "a a" '(org-agenda :wk "org-agenda")
    "a /" '(consult-org-agenda :wk "consult-org-agenda")
    "A" '((lambda ()
	    (interactive)
	    (find-file
	     (expand-file-name "org/" user-emacs-directory))) :wk "org-agenda")
	;; buffer manipulation
    "q" '(delete-window :wk "delete window")
	"D" '(diff-hl-diff-goto-hunk :wk "diff-hl-diff-goto-hunk")
    "k" '(kill-buffer-and-window :wk "kill buffer and window")
    "W" '(toggle-truncate-lines :wk "toggle truncate lines")
    ";" '(comment-line :wk "comment line")
	;; finding files or regex
    "/" '(rg-literal :wk "rg literal")
    "f" '(find-file :wk "find file")
	"." '(dired :wk "dired")
    "," '(consult-buffer :wk "find buffer")
    "<" '((lambda () (interactive)
	    (call-interactively #'find-file-other-window)
	    (evil-window-move-far-left))
	  :wk "find file other window")
    ">" '((lambda () (interactive)
	    (call-interactively #'find-file-other-window)
	    (evil-window-move-far-right))
	  :wk "find file other window")
	;; executing commands
    "c c" '(compile :wk "compile")
    "b r" '(quickrun :wk "quickrun") ; might need `quickrun-shell' to update dir
    "b s" '(quickrun-shell :wk "quickrun-shell")
    ":" '(execute-extended-command :wk "execute extended command") ; M-x
    "!" '(shell-command :wk "shell command")
    "&" '(async-shell-command :wk "async shell command")
    "x" '(execute-extended-command :wk "M-x")
	;; project commands
	"p SPC" '(ghostel-project :wk "ghostel-project")
    "p s" '(project-switch-project :wk "project switch")
    "p k" '(project-kill-buffers :wk "project kill buffers")
    "p f" '(project-find-file :wk "project find file")
    "p c" '(project-compile :wk "project compile")
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

;; required package for completion
(use-package transient)

;; for ripgrep usage
;; in rg menu
;; - "t" -> rerun search, change literal
;; - "r" -> rerun search, change regexp
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
(use-package doom-themes
  :config
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; modeline
(use-package doom-modeline
  :config
  (setq doom-modeline-icon nil)
  :init (doom-modeline-mode 1))

;; embedded terminal
(use-package ghostel
  :after (evil-collection general)
  :config
  (general-nmap 'ghostel-mode-map
    "q" 'quit-window))

;; tree sitter
(use-package treesit
  :straight nil
  :config
  (setq treesit-font-lock-level 4) ; maximum highlighting
  (setq major-mode-remap-alist
	'((python-mode . python-ts-mode)
	  (c-mode . c-ts-mode)
	  (clojure-mode . clojure-ts-mode))))

;; folding
(use-package treesit-fold
  :straight (:host github :repo "emacs-tree-sitter/treesit-fold")
  :hook
  ((typescript-ts-mode . treesit-fold-mode)
   (python-ts-mode . treesit-fold-mode)
   (markdown-ts-mode . treesit-fold-mode)
   (c-ts-mode . treesit-fold-mode)))

;; language configs

;; running programs
(use-package quickrun
  :config
  ;; must kill window to reset default directory
  (general-nmap 'quickrun--mode-map
	"q" 'kill-buffer-and-window)
  ;; odin
  (quickrun-add-command "odin"
   '((:command . "odin")
     (:exec . ("%c build . -out:%e" "%e"))
     (:tempfile . nil)
	 (:remove . ("%e")))
   :mode 'odin-mode)
  ;; python
  (quickrun-add-command "uv"
	'((:command . "uv")
	  (:exec . ("uv run %s"))
	  (:tempfile . nil))
	:default "python")
  ;; typescript
  (quickrun-add-command "bun"
	'((:command . "bun")
      (:exec . "%c %s")
	  (:tempfile . nil))
	:default "typescript"))

;; parens coloring
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

;; parenthesis wrangling
;; `M-r' raise sexp
;; `M-s' splice sexp
;; `M-S' split sexp
(use-package paredit
  :after (clojure-ts-mode cider)
  :commands paredit-mode
  :hook
  (clojure-ts-mode . paredit-mode)
  (emacs-lisp-mode . paredit-mode)
  :config
  (dolist (lisp-maps (list clojure-ts-mode-map emacs-lisp-mode-map))
    (bind-key "M-l" #'paredit-forward-slurp-sexp lisp-maps)
	(bind-key "M-h" #'paredit-backward-slurp-sexp lisp-maps)))

;; better evil integration
(use-package enhanced-evil-paredit
  :commands enhanced-evil-paredit-mode
  :hook (paredit-mode . enhanced-evil-paredit-mode))

;; completion
(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-quit-at-boundary t)
  (corfu-quit-no-match t)
  :init
  (global-corfu-mode))

;; completion sources
(use-package cape
  ;; 'C-c p ?' to for help.
  :bind ("C-c p" . cape-prefix-map)
  :init
  ;; globally add to value of `completion-at-point-functions'
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

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
  (add-to-list 'eglot-ignored-server-capabilities :hoverProvider)
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

;; git interface
(use-package magit
  :after (evil-collection transient)
  :config
  (global/leader-keys
    "g" '(magit-status :wk "magit-status")))

;; git visual and navigation
(use-package diff-hl
  :after (general)
  :config
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (general-nmap
	"] d" '(diff-hl-next-hunk :wk "diff-hl-next hunk")
	"[ d" '(diff-hl-previous-hunk :wk "diff-hl-previous-hunk"))
  (global-diff-hl-mode))

;; jumping without lsp
(use-package dumb-jump
  :custom
  (dumb-jump-prefer-searcher 'rg)
  (xref-show-definitions-function #'consult-xref)
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;; docker
(use-package docker
  :custom
  (docker-command "podman")
  (docker-compose-command "podman-compose")
  (docker-container-tramp-method "docker")
  :bind ("C-c d" . docker))

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

;; markdown
(use-package markdown-ts-mode
  :mode ("\\.md\\'" . markdown-ts-mode))

;; clojure
(use-package clojure-ts-mode)

;; clojure repl
(use-package cider
  :after clojure-ts-mode
  :config
  (global/leader-keys
   :keymaps 'clojure-ts-mode-map
   "n" '(cider-ns-map :wk "cider ns map")))

;; go
(use-package go-ts-mode
  :straight nil
  :mode "\\.go\\'"
  :custom
  (go-ts-mode-indent-offset 4))

;; lean4
(use-package nael
  :hook
  (nael-mode . (lambda ()
		 (setq-local indent-tabs-mode nil))))

;; nim
(use-package nim-mode)

;; odin
(use-package odin-mode
  :straight (:host github :repo "mattt-b/odin-mode")
  :hook
  (odin-mode . (lambda () (setq-local compile-command "odin build ."))))

;; scheme
(use-package geiser-chez)

;; typescript
(use-package typescript-ts-mode
  :straight nil
  :mode
  (("\\.js\\'"  . typescript-ts-mode)
   ("\\.mjs\\'" . typescript-ts-mode)
   ("\\.mts\\'" . typescript-ts-mode)
   ("\\.cjs\\'" . typescript-ts-mode)
   ("\\.ts\\'"  . typescript-ts-mode)))

;; direnv
(use-package envrc
  :config
  (envrc-global-mode))

;; debugging
;;; dependency
(use-package repeat
  :straight nil
  :custom
  (repeat-mode t))

;;; debug adapter
(use-package dape)

;; org
(use-package org
  :straight nil
  :config
  (require 'org-tempo))

;;; config.el ends here
