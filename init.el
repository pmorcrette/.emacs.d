;; Minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

;; Lower threshold back to 8 MiB (default is 800kB)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (expt 2 23))))

;; Remove some stuff from UI & Startup
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


;; setup MELPA
(require 'package)
(setq package-archives
'(("melpa" . "https://melpa.org/packages/")
("elpa" . "https://elpa.gnu.org/packages/")
("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;; Setup packaging system
(require 'use-package)
(setq use-package-always-ensure t)



