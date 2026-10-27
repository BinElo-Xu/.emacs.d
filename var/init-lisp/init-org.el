;;; -*- lexical-binding: t -*-

;; Org mode is a major mode designed for organizing notes, planning, task
;; management, and authoring documents using plain text with a simple and
;; expressive markup syntax. It supports hierarchical outlines, TODO lists,
;; scheduling, deadlines, time tracking, and exporting to multiple formats
;; including HTML, LaTeX, PDF, and Markdown.
(use-package org
  :commands (org-mode org-version)
  :mode
  ("\\.org\\'" . org-mode)
  :init
  (setq org-hide-leading-stars t)
  (setq org-startup-indented t)
  (setq org-adapt-indentation nil)
  (setq org-edit-src-content-indentation 0)
  ;; (setq org-fontify-done-headline t)
  ;; (setq org-fontify-todo-headline t)
  ;; (setq org-fontify-whole-heading-line t)
  ;; (setq org-fontify-quote-and-verse-blocks t)
  (setq org-startup-truncated t)
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   ("C-c l" . org-store-link)
   ))

;; Capturing template
(setq org-capture-templates
      `(("t" "todo" entry (file "/home/elo/Notes/agenda/inbox.org")  ; "" => `org-default-notes-file'
         "* next %?\n%u\n" :clock-resume t)
        ("n" "note" entry (file "/home/elo/Notes/agenda/inbox.org")
         "* %? :NOTE:\n%U\n%a\n" :clock-resume t)
        ))

;; add some file to org-agenda file.
(setq org-agenda-files '("/home/elo/Notes/agenda/inbox.org"
                         "/home/elo/Notes/agenda/todo.org"
                         "/home/elo/Notes/agenda/habbits.org"
                         "/home/elo/Notes/agenda/archive.org"
                         ))


;; when cursor is on the link, link content will 
;; appear. Hidding when cursor leave. 
(use-package org-appear
  :commands org-appear-mode
  :hook (org-mode . org-appear-mode))

;; To-do settings
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
              (sequence "PROJECT(p)" "|" "DONE(d!/!)" "CANCELLED(c@/!)")
              (sequence "WAITING(w@/!)" "DELEGATED(e!)" "HOLD(h)" "|" "CANCELLED(c@/!)")))
      org-todo-repeat-to-state "NEXT")

(setq org-todo-keyword-faces
      (quote (("NEXT" :inherit warning)
              ("PROJECT" :inherit font-lock-string-face))))

(setq-default org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3))


;; Agenda views

(setq org-stuck-projects
      '("-INBOX/PROJECT" ("NEXT")))

(let ((active-project-match '(car org-stuck-projects)))
  (setq org-agenda-compact-blocks t
        org-agenda-sticky t
        org-agenda-start-on-weekday nil
        org-agenda-span 'day
        org-agenda-include-diary nil
        org-agenda-sorting-strategy
        '((agenda habit-down time-up effort-up category-keep)
          (todo category-up effort-up)
          (tags category-up effort-up)
          (search category-up))
        org-agenda-window-setup 'current-window
        org-agenda-custom-commands
        `(("N" "Notes" tags "NOTE"
           ((org-agenda-overriding-header "Notes")
            (org-tags-match-list-sublevels t)))
          ("g" "GTD"
           ((agenda "" nil)
            (tags "INBOX"
                  ((org-agenda-overriding-header "Inbox")
                   (org-tags-match-list-sublevels nil)))
            (stuck ""
                   ((org-agenda-overriding-header "Stuck Projects")
                    (org-agenda-tags-todo-honor-ignore-options t)
                    (org-tags-match-list-sublevels t)
                    (org-agenda-todo-ignore-scheduled 'future)))
            (tags-todo "-INBOX"
                       ((org-agenda-overriding-header "Next Actions")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("HOLD" "WAITING"))
                                (org-agenda-skip-entry-if 'nottodo '("NEXT")))))
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(todo-state-down effort-up category-keep))))
            (tags-todo ,active-project-match
                       ((org-agenda-overriding-header "Projects")
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "-INBOX/-NEXT"
                       ((org-agenda-overriding-header "Orphaned Tasks")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("PROJECT" "HOLD" "WAITING" "DELEGATED"))
                                (org-agenda-skip-subtree-if 'nottodo '("TODO")))))
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/WAITING"
                       ((org-agenda-overriding-header "Waiting")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/DELEGATED"
                       ((org-agenda-overriding-header "Delegated")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "-INBOX"
                       ((org-agenda-overriding-header "On Hold")
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("WAITING"))
                                (org-agenda-skip-entry-if 'nottodo '("HOLD")))))
                        (org-tags-match-list-sublevels nil)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            ;; (tags-todo "-NEXT"
            ;;            ((org-agenda-overriding-header "All other TODOs")
            ;;             (org-match-list-sublevels t)))
            )))))

(add-hook 'org-agenda-mode-hook 'hl-line-mode)

;;; 以下内容添加到 post-init.el

;; 普通笔记：~/Projects/Notes/notes/
;; 每日日记：~/Projects/Notes/journal/

(use-package org-roam
  :ensure t
  :commands (org-roam-capture org-roam-db-sync)
  :init
  ;; 在首次加载 Org-roam 前就设置路径。
  (setq org-roam-directory
        (expand-file-name "~/Notes/")
        org-roam-dailies-directory "journal/")

  :custom
  (org-roam-completion-everywhere t)
  (org-roam-node-display-template "${tags:50} ${title:*}")

  ;; 普通笔记统一创建在 notes/ 子目录。
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :target
      (file+head "notes/${slug}.org"
                 "#+title: ${title}\n")
      :unnarrowed t)))

  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   :map org-mode-map
   ("C-M-i" . completion-at-point))

  :config
  (make-directory
   (expand-file-name "notes/" org-roam-directory) t)
  (make-directory
   (expand-file-name org-roam-dailies-directory
                     org-roam-directory)
   t)

  ;; 首次使用 Org-roam 时开启数据库自动同步。
  (org-roam-db-autosync-mode 1))


;; Dailies 随 Org-roam 一起加载，不在启动时强制加载 Org-roam。
(use-package org-roam-dailies
  :ensure nil                       ; 随 org-roam 提供
  :after org-roam
  :demand t

  :custom
  (org-roam-dailies-capture-templates
   '(("d" "default" entry
      "* %?"
      :target
      (file+head "%<%Y-%m-%d>.org"
                 "#+title: %<%Y-%m-%d>\n"))))

  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)

  :bind
  (:map org-roam-dailies-map
        ("Y" . org-roam-dailies-capture-yesterday)
        ("T" . org-roam-dailies-capture-tomorrow)))


;; 图谱：按快捷键时才加载并启动。
(use-package org-roam-ui
  :ensure t
  :after org-roam
  :commands org-roam-ui-mode
  :bind
  ("C-c n u" . org-roam-ui-mode)

  :custom
  (org-roam-ui-sync-theme t)
  (org-roam-ui-follow t)
  (org-roam-ui-update-on-save t)
  (org-roam-ui-open-on-start t))


;; 已有 consult 配置时，保留原配置即可，不必重复声明。
(use-package consult
  :ensure t
  :defer t)


;; 首次加载 Org-roam 后启用 Consult 集成。
(use-package consult-org-roam
  :ensure t
  :after org-roam
  :demand t

  :bind
  (("C-c n b" . consult-org-roam-backlinks)
   ("C-c n s" . consult-org-roam-search))

  :config
  (consult-org-roam-mode 1)

  ;; 禁用这几个 Consult 命令的自动预览。
  (consult-customize
   consult-org-roam-backlinks
   consult-org-roam-file-find
   consult-org-roam-search
   :preview-key nil))

(provide 'init-org)

;; init-org.el ends here.
