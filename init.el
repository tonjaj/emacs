;;; Code:
;; custom-set
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("f0dc4ddca147f3c7b1c7397141b888562a48d9888f1595d69572db73be99a024" "b35a14c7d94c1f411890d45edfb9dc1bd61c5becd5c326790b51df6ebf60f402" "1c082c9b84449e54af757bcae23617d11f563fc9f33a832a8a2813c4d7dfb652" "3a3de615f80a0e8706208f0a71bbcc7cc3816988f971b6d237223b6731f91605" "a566448baba25f48e1833d86807b77876a899fc0c3d33394094cf267c970749f" "93a0885d5f46d2aeac12bf6be1754faa7d5e28b27926b8aa812840fe7d0b7983" default)))
 '(package-selected-packages
   (quote
    (xcscope markdown-mode+ markdown-mode flx-isearch flycheck-golangci-lint flycheck-clang-analyzer flycheck exec-path-from-shell use-package doom-themes projectile ido-completing-read+ ## ido-vertical-mode flx-ido magit)))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;;;;;;;;;;
;;; Personal additions
;;; Inspired a lot by https://gist.github.com/huytd/6b785bdaeb595401d69adc7797e5c22c

;; For performance: 40MB garbage collection mem threshold
(setq gc-cons-threshold 40000000)

;; Use bash as shell
(setq explicit-shell-file-name "/bin/bash")
(setq explicit-bash-args '("--noediting" "--login" "-i"))
(setq tramp-default-method "ssh")
;; trailing whitespace
(setq show-trailing-whitespace t)

;; Package configs
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"   . "http://orgmode.org/elpa/")
                         ("gnu"   . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
;; End of package configs
;; Customize only below this line

;;;;;;
;;; Environment & UI

;; theme
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-vibrant t))

;; Dark titlebar for macOS
(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (setq ns-use-proxy-icon nil))

;; Show or hide current buffer file path. Uncomment one of the two next lines
;(setq frame-title-format nil)
(setq frame-title-format ; Show whole file path
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))


;; Pretty font
;(add-to-list 'default-frame-alist '(font . "Iosevka-14"))
;; UI
(cond ((version<= "26.0.50" emacs-version ) (global-display-line-numbers-mode))
      (t (global-linum-mode 1)))
(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)
;; Only show right fringe
(fringe-mode '(0 . nil))
;; Show matching parens.
(setq show-paren-delay 0)
(show-paren-mode  1)
;; Show keystrokes instantly
(setq echo-keystrokes -1)

;; @TODO Add hook for this, bind it to a mode
;; Display newlines as '¬'
(standard-display-ascii ?\n "¬\n")

;; Startup
(setq inhibit-startup-screen t)
(setq initial-scratch-message ";; Welcome!")

;;;;;;
;;; Keystroke customization

;; moving cursor between windows
(global-set-key (kbd "<M-left>")  'windmove-left)
(global-set-key (kbd "<M-right>") 'windmove-right)
(global-set-key (kbd "<M-up>")    'windmove-up)
(global-set-key (kbd "<M-down>")  'windmove-down)

(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 4)            ;; but maintain correct appearance
(setq tab-always-indent 'complete)


; macOS: use left alt for meta, and right-alt for option
(when (eq system-type 'darwin)
  (setq mac-option-modifier 'meta)
  (setq mac-right-option-modifier 'none))


;;;;;;
;;; External packages

;; command autocompletion with ido
(use-package ido
  :ensure t
  :init
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil)
  (setq ido-everywhere t)
  :config
  (ido-mode 1))
(use-package ido-completing-read+
  :ensure t
  :config
  (ido-ubiquitous-mode 1))

;; fuzzy searching with flx
(use-package flx
  :ensure t)
(use-package flx-ido
  :ensure t
  :init
  (setq flx-ido-threshold 1000)
  :config
  (flx-ido-mode 1))
(use-package flx-isearch ; C-SHIFT-s
  :ensure t
  :config
  (global-set-key (kbd "C-S-s") #'flx-isearch-forward)
  (global-set-key (kbd "C-S-r") #'flx-isearch-backward))

;; Inherit path from Terminal
(use-package exec-path-from-shell
   :ensure t
   :config
   (exec-path-from-shell-initialize))

;; code autocompletion with company
(use-package company
  :ensure t
  :init
  (setq company-minimum-prefix-length 3)
  (setq company-auto-complete nil)
  (setq company-idle-delay 0)
  (setq company-require-match 'never)
  (setq company-frontends
  '(company-pseudo-tooltip-unless-just-one-frontend
    company-preview-frontend
    company-echo-metadata-frontend))
  :config
  (global-company-mode 1))

;;;;;;
;;; Language support packages


(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode))
(use-package flycheck-golangci-lint
  :ensure t
  :config  (add-hook 'flycheck-mode-hook #'flycheck-golangci-lint-setup))
(use-package flycheck-clang-analyzer
  :ensure t
  :init
  (flycheck-clang-analyzer-setup))

;; markdown
(use-package markdown-mode
  :ensure t
 ; :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-command "pandoc")
  (setq markdown-enable-math t)
  (setq markdown-fontify-code-blocks-natively t)
  ;:config
  )

(use-package markdown-mode+
  :ensure t)

;; LSP: Consider adding
;; (use-package lsp-mode
;;   :ensure t
;;   :init
;;   (add-hook 'prog-major-mode #'lsp-prog-major-mode-enable))

;; (use-package lsp-ui
;;   :ensure t
;;   :init
;;   (add-hook 'lsp-mode-hook 'lsp-ui-mode))


(provide 'init)
;;; init.el ends here
