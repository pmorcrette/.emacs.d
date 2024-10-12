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

;; here goes packages
(use-package all-the-icons
      :if
(display-graphic-p))

(use-package all-the-icons-dired
      :after all-the-icons
      :hook
(dired-mode . all-the-icons-dired-mode))

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

