;; Minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

;; Lower threshold back to 8 MiB (default is 800kB)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (expt 2 23))))

;; Setting some sane defaults
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(display-battery-mode 1)
(menu-bar-mode -1)
(setq visible-bell t)
(setq inhibit-startup-message -1)
(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8-unix)
(setq display-time-string-forms
'((propertize
(concat " " 24-hours ":" minutes " ")
'face 'egoge-display-time)))
(display-time-mode 1)
(setq display-time-default-load-average nil)

(fset 'yes-or-no-p 'y-or-n-p)




;; Setup packaging system
(require 'use-package)
(setq use-package-always-ensure t)


;; here goes packages
(use-package all-the-icons
  :load-path "~/.emacs.d/local-list/all-the-icons/"
      :if
(display-graphic-p))

(use-package all-the-icons-dired
  :load-path "~/.emacs.d/local-list/all-the-icons-dired/"
      :after all-the-icons
      :hook
(dired-mode . all-the-icons-dired-mode))

;; let's add some meow to Emacs

(use-package catppuccin-theme
  :load-path "~/.emacs.d/local-list/catppuccin-theme/"
  :init
  (load-theme 'catppuccin :no-confirm)
  :config
  (setq catppuccin-flavor 'macchiato)
  (catppuccin-reload))

;; And some cool modeline !

(use-package telephone-line
  :load-path "~/.emacs.d/local-list/telephone-line"
  :init
  (telephone-line-mode 1))

(use-package general
  :load-path "~/.emacs.d/local-list/general")

(use-package marginalia
  :load-path "~/.emacs.d/local-list/marginalia"
        :general
(:keymaps 'minibuffer-local-map
         "M-A" 'marginalia-cycle)
:custom
(marginalia-max-relative-age 0)
(marginalia-align 'right)
:init
(marginalia-mode)
:config
(all-the-icons-completion-marginalia-setup))

(use-package all-the-icons-completion
  :load-path "~/.emacs.d/local-list/all-the-icons-completion"
  :after
  (marginalia all-the-icons))

(use-package vertico
  :load-path "~/.emacs.d/local-list/vertico"
  :config
(vertico-reverse-mode)
:init
(vertico-mode))


(use-package corfu
  :load-path "~/.emacs.d/local-list/corfu"
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0)
  (corfu-separator ?\s)
  (corfu-popupinfo-delay 0)
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  :general
  (:keymaps 'corfu-map
            "SPC" 'corfu-insert-separator))


(use-package consult
  :load-path "~/.emacs.d/local-list/consult"
    :hook
(completion-list-mode . consult-preview-at-point-mode)
:init
(setq register-preview-delay 0.5
          register-preview-function #'consult-register-format)
(advice-add #'register-preview :override #'consult-register-window)
(setq xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref)
:config
(consult-customize
     consult-theme :preview-key
'(:debounce 0.2 any)
consult-ripgrep consult-git-grep consult-grep
     consult-bookmark consult-recent-file consult-xref
     consult--source-bookmark consult--source-file-register
     consult--source-recent-file consult--source-project-recent-file
     :preview-key
'(:debounce 0.4 any))
(setq consult-narrow-key "<")
:general
("M-y" #'consult-yank-from-kill-ring)
("C-x b" #'consult-buffer))


(use-package kind-icon
  :load-path "~/.emacs.d/local-list/kind-icon"
  :ensure t
  :after corfu
  :custom
(kind-icon-default-face 'corfu-default)
; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package which-key
  :init
(which-key-mode)
:diminish which-key-mode)

(use-package orderless
  :load-path "~/.emacs.d/local-list/orderless"
  :init
  (setq completion-styles
	'(orderless partial-completion basic)
	completion-category-defaults nil
	completion-category-overrides nil))

;; Some eshell stuff

(use-package eshell-git-prompt
  :load-path "~/.emacs.d/local-list/eshell-git-prompt")
(use-package eshell
  :load-path "~/.emacs.d/local-list/eshell"
  :config
  (eshell-git-prompt-use-theme 'multiline2)
  (setq eshell-history-size         10000
	eshell-buffer-maximum-lines 10000
	eshell-hist-ignoredups t
	eshell-scroll-to-bottom-on-input t))

(defalias 'ff 'find-file-other-window)

(defun esh(name)
  (interactive "sName: ")
  (eshell 'N)
  (if (not (= (length name) 0))
      (rename-buffer name)))


;; Setting up GIT with a bit of magic
(use-package magit) ;; <== MAGIC BE HERE !!!
(use-package forge
  :load-path "~/.emacs.d/local-list/forge"
  :after magit)

;; Some useful editor config
(column-number-mode)
(global-display-line-numbers-mode t)

(use-package rainbow-delimiters ;; it's for shit & giggles. Absolutely not to save my eyes some pain, I swear !
  :load-path "~/.emacs.d/local-list/rainbow-delimiter"
  :hook
  (prog-mode . rainbow-delimiters-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Here be knowledge ! ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org-roam
  :load-path "~/.emacs.d/local-list/org-roam"
  :init
  (setq org-roam-directory (file-truename "~/.emacs.d/org"))
  (org-roam-db-autosync-mode))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The heavy lifting is here                                          ;;
;; Where we transform emacs as editor into a super duper powerful IDE ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package direnv
        :config
(direnv-mode))

;; this is where we jury rig lsp with orderless, corfu, which-key and direnv 
(use-package lsp-mode
  :load-path "~/.emacs.d/local-list/lsp-mode"
  :custom
  (lsp-completion-provider :none)
  :init
  (defun my/lsp-mode-setup-completion
      ()
    (setf
     (alist-get 'styles
                (alist-get 'lsp-capf completion-category-defaults))
     '(orderless)))
  ;; Configure orderless
  (advice-add 'lsp :before #'direnv-update-environment)
  :hook
  (lsp-completion-mode . my/lsp-mode-setup-completion)
  (lsp-mode .
            (lambda
              ()
              (let
                  ((lsp-keymap-prefix "C-c l"))
                (lsp-enable-which-key-integration))))
  :config
  (lsp-enable-which-key-integration t)
  (define-key lsp-mode-map
              (kbd "C-c l")
              lsp-command-map))




(use-package lsp-ui
  :load-path "~/.emacs.d/local-list/lsp-ui"
  :hook
  (lsp-mode . lsp-ui-mode))
  
;; This is the power of the outer gods at your fingertips
(use-package yasnippet
  :load-path "~/.emacs.d/local-list/yasnippet"
  :ensure t
  :hook ((lsp-mode . yas-minor-mode)))

;; And this is the outer gods 
(use-package yasnippet-snippets
  :load-path "~/.emacs.d/local-list/yasnippet-snippets")

(electric-pair-mode t)

;; Let's set things up for POSIX Shell scripting (all other shells are for the weak !)
(use-package flymake) ;; we use flymake here for sh-script which run shellcheck for us
(use-package sh-script
  :hook (sh-mode . flymake-mode))
(use-package shfmt
  :load-path "~/.emacs.d/local-list/emacs-shfmt"
  :hook
  (sh-mode . shfmt-on-save-mode))

;; Snake incoming !

;; Config for python
(use-package python-mode
  :load-path "~/.emacs.d/local-list/python-mode"
  :ensure t
  :hook
  (python-mode . lsp-deferred))

(use-package lsp-pyright
  :load-path "~/.emacs.d/local-list/lsp-pyright"
  :ensure t
  :hook
  (python-mode .
	       (lambda ()
		 (require 'lsp-pyright)
		 (lsp-deferred))))

;; Json without braces

(use-package yaml-mode
  :load-path "~/.emacs.d/local-list/yaml-mode")
(use-package highlight-indentation
  :load-path "~/.emacs.d/local-list/highlight-indent-guides")

(add-hook 'yaml-mode-hook
	  (lambda ()
	    (define-key yaml-mode-map "\C-m" 'newline-and-indent)
	    (highlight-indentation-mode)))

;; Ensure syntax coloration for yaml
(add-hook 'yaml-mode-hook
  (lambda ()
    (face-remap-add-relative 'font-lock-variable-name-face
                             (list :foreground (catppuccin-get-color 'blue)))))

;; Let's do some crabby things
(use-package rustic
:load-path "~/.emacs.d/local-list/rustic"
  :ensure t
  :config
  (setq rustic-format-on-save nil)
  :custom
  (rustic-cargo-use-last-stored-arguments t))



;; Some keybinds under my own prefix to go faaaaasst
(defvar-keymap quick-map)
(define-key global-map (kbd "M-SPC") quick-map)
(general-def quick-map
  :keymaps quick-map
  "f" 'consult-fd
  "g" 'consult-ripgrep
  "SPC" 'org-roam-capture)
