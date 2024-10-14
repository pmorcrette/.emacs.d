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


;; setup MELPA
(require 'package)
(setq package-archives
'(("melpa" . "https://melpa.org/packages/")
("elpa" . "https://elpa.gnu.org/packages/")
("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;; Setup packaging system
(require 'use-package)
(setq use-package-always-ensure t)

;; Straight.el bootstrap

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; here goes packages
(use-package all-the-icons
      :if
(display-graphic-p))

(use-package all-the-icons-dired
      :after all-the-icons
      :hook
(dired-mode . all-the-icons-dired-mode))

;; let's add some meow to Emacs

(use-package catppuccin-theme
  :init
  (load-theme 'catppuccin :no-confirm)
  :config
  (setq catppuccin-flavor 'macchiato)
  (catppuccin-reload))

;; And some cool modeline !

(use-package telephone-line
  :init
  (telephone-line-mode 1))

(use-package general)
(use-package marginalia
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
  :after
  (marginalia all-the-icons))

(use-package vertico
  :config
(vertico-reverse-mode)
:init
(vertico-mode))


(use-package corfu
  :straight
  (corfu :files
         (:defaults "extensions/*")
         :includes
         (corfu-info corfu-history corfu-popupinfo))
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
("C-x b" #'consult-buffer)
("C-x C-/" #'consult-find)
("C-x M-/" #'consult-grep))

(use-package kind-icon
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
  :init
  (setq completion-styles
	'(orderless partial-completion basic)
	completion-category-defaults nil
	completion-category-overrides nil))

;; Some eshell stuff

(use-package eshell-git-prompt)
(use-package eshell
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
  :after magit)

;; Some useful editor config
(column-number-mode)
(global-display-line-numbers-mode t)

(use-package rainbow-delimiters ;; it's for shit & giggles. Absolutely not to save my eyes some pain, I swear !
  :hook
  (prog-mode . rainbow-delimiters-mode))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The heavy lifting is here                                          ;;
;; Where we transform emacs as editor into a super duper powerful IDE ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package direnv
        :config
(direnv-mode))

;; this is where we jury rig lsp with orderless, corfu, which-key and direnv 
(use-package lsp-mode
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
  :hook
  (lsp-mode . lsp-ui-mode))
  
;; This is the power of the outer gods at your fingertips
(use-package yasnippet
  :ensure t
  :hook ((lsp-mode . yas-minor-mode)))

;; And this is the outer gods 
(use-package yasnippet-snippets)

(electric-pair-mode t)

;; Let's set things up for POSIX Shell scripting (all other shells are for the weak !)
(use-package flymake) ;; we use flymake here for sh-script which run shellcheck for us
(use-package sh-script
  :hook (sh-mode . flymake-mode))
(use-package shfmt
  :hook
  (sh-mode . shfmt-on-save-mode))

;; Snake incoming !

;; Config for python
(use-package python-mode
  :ensure t
  :hook
  (python-mode . lsp-deferred))

(use-package lsp-pyright
  :ensure t
  :hook
  (python-mode .
	       (lambda ()
		 (require 'lsp-pyright)
		 (lsp-deferred))))

;; Json without braces

(use-package yaml-mode)

(use-package highlight-indentation)

(add-hook 'yaml-mode-hook
	  (lambda ()
	    (define-key yaml-mode-map "\C-m" 'newline-and-indent)
	    (highlight-indentation-mode)))
