;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'visual)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(after! org-journal
                     (setq org-journal-dir "~/org/journal/"
                           org-journal-file-format "%Y_%m_%d.org"
                          org-journal-enable-agenda-integration t))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;; Terminal compatibility

;; Ghostty sets TERM=xterm-ghostty. Emacs does not ship a matching
;; term/xterm-ghostty.el file yet, so reuse the standard xterm initialization.

(add-to-list 'term-file-aliases '("xterm-ghostty" . "xterm"))
; clipetty sends clipboard data via OSC 52, which Ghostty handles natively.
(use-package! clipetty
  :hook (after-init . global-clipetty-mode))

;; Make normal-mode `p` paste from the macOS system clipboard, matching Vim's
;; `clipboard=unnamedplus` behavior.
(after! evil
  (setq select-enable-clipboard t
        save-interprogram-paste-before-kill t
        evil-default-register ?+))

(map!
    :nvm "k" #'evil-previous-visual-line
    :nvm "k"   #'evil-previous-visual-line
    :o   "k"   #'evil-previous-line
    :nvm "j" #'evil-next-visual-line
    :o   "j" #'evil-next-line
 )

(map! :leader
      (:prefix ("o" . "org mode")
               (:prefix ("j" . "org-mode journal")
                        :desc "Open last journal entry" "o" #'org-journal-open-current-journal-file
                        :desc "Create new journal entry" "j" #'org-journal-new-entry)))
;; set up org agenda reading
(after! org
    (setq org-directory "~/org/"
        org-agenda-files (append
                            (directory-files-recursively (expand-file-name "~/org/") "\\.org$")
                            (directory-files-recursively (expand-file-name "~/wci/") "\\.org$")
                            (directory-files-recursively (expand-file-name "~/simkincpa/") "\\.org$")
                        )
    )
)

;;; Mail

(after! mu4e
  (setq mu4e-maildir (expand-file-name "~/.mail")
        mu4e-get-mail-command "mbsync gmail"
        sendmail-program (executable-find "msmtp")
        send-mail-function #'sendmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail)

  (set-email-account! "gmail"
    '((mu4e-sent-folder       . "/gmail/[Gmail]/Sent Mail")
      (mu4e-drafts-folder     . "/gmail/[Gmail]/Drafts")
      (mu4e-trash-folder      . "/gmail/[Gmail]/Trash")
      (mu4e-refile-folder     . "/gmail/[Gmail]/All Mail")
      (smtpmail-smtp-user     . "esimkin@westcoastinformatics.com")
      (user-mail-address      . "esimkin@westcoastinformatics.com")
      (user-full-name         . "elijahsimkin"))
    t))

;; restore vanilla vim s substitute functionality
;; Allow for motions inside the mini-buffer similar to neovim's ;;
(define-key minibuffer-local-map (kbd "C-f") 'evil-command-window)

(map! :nv (kbd "s") #'evil-substitute)
(map! :map text-modemap
      :n (kbd "-") (lambda ()
                     (interactive)
                     (if buffer-file-name
                         (dired (file-name-directory buffer-file-name))
                        (dired default-directory)
                    )))

;;; WCI Java / Gradle

(after! lsp-java
  ;; The EVS REST API project targets Java 17 through Gradle's toolchain, while
  ;; JDTLS itself can run on the installed Homebrew JDK.
  (setq lsp-java-java-path "/opt/homebrew/opt/openjdk@21/bin/java"
        lsp-java-save-actions-organize-imports t))

(after! projectile
  (put 'projectile-project-compilation-cmd 'safe-local-variable #'stringp)
  (put 'projectile-project-test-cmd 'safe-local-variable #'stringp)
  (put 'projectile-project-run-cmd 'safe-local-variable #'stringp)
  (projectile-register-project-type
   'wci-gradle
   '("gradlew" "build.gradle")
   :project-file "build.gradle"
   :compile "GRADLE_USER_HOME=.gradle-home ./gradlew clean build -x zipFile"
   :test "GRADLE_USER_HOME=.gradle-home ./gradlew test"
   :run "GRADLE_USER_HOME=.gradle-home ./gradlew bootRun"))
