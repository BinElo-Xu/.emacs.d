;;; -*- lexical-binding: t -*-

(let ((inhibit-redisplay t))
  ;; Disable all active themes
  (mapc #'disable-theme custom-enabled-themes)
  ;; Load the built-in theme
  (load-theme 'tango-dark t))

(provide 'init-theme)

