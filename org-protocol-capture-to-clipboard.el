;; -*- lexical-binding: t -*-
;;; org-protocol-capture-to-clipboard.el --- Capture webpage content to Org clipboard

;; Author: Daniel Krizian
;; Maintainer: Daniel Krizian
;; Version: 1.0
;; Package-Requires: ((emacs "27.1") (org "9.4") (org-protocol-capture-html "0.1"))
;; Homepage: https://github.com/danielkrizian/org-protocol-capture-to-clipboard
;; Keywords: org, clipboard, capture, web

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This package provides a way to capture selected webpage content,
;; convert it to Org-mode using Pandoc, and copy it to the clipboard
;; with an Org-style hyperlink for the source.

;;; Code:

(require 'org-protocol)
(require 'org-protocol-capture-html)   ;; https://github.com/alphapapa/org-protocol-capture-html

(defun org-protocol-capture-html--to-clipboard (data)
  "Process HTML content from DATA via Pandoc and copy the Org-mode text to the clipboard.
Uses `make-process` to avoid creating a temporary buffer."

  (unless org-protocol-capture-html-pandoc-no-wrap-option ;; Ensure Pandoc wrap option is initialized
    (org-protocol-capture-html--define-pandoc-wrap-const))

  (unless (executable-find "pandoc") (error "[ERROR] Pandoc is not available in exec-path."))

  (let* ((content (or (org-protocol-capture-html--nbsp-to-space (string-trim (plist-get data :body))) ""))
         (title (or (org-protocol-capture-html--nbsp-to-space (string-trim (plist-get data :title))) ""))
         (url (org-protocol-sanitize-uri (plist-get data :url)))
         (orglink (org-make-link-string url (if (string-match "[^[:space:]]" title) title url)))
         (pandoc-output "")) ;; Placeholder for the output
    (kill-new orglink)
    (condition-case err
        (make-process
         :name "pandoc-process"
         :command `("pandoc" "-f" "html" "-t" "org" ,org-protocol-capture-html-pandoc-no-wrap-option)
         :buffer nil
         :connection-type 'pipe
         :filter (lambda (_proc output)
                   (setq pandoc-output (concat pandoc-output output)))
         :sentinel (lambda (proc event)
                     (when (string= event "finished\n")
                       (progn
                         (kill-append (concat "\n" (string-trim pandoc-output)) nil)
                         (message "Converted org content copied to clipboard from url: %s" (string-trim url))
                         ))))
      (error
       (message "[ERROR] Failed to start Pandoc process: %s" err)))

    ;; (process-send-string "pandoc-process" (concat orglink "\n\n" content))
    (process-send-string "pandoc-process" content)
    (process-send-eof "pandoc-process")
    (kill-buffer "pandoc-process")
    ))

(add-to-list 'org-protocol-protocol-alist
             '("capture-html-to-clipboard"
               :protocol "capture-html-to-clipboard"
               :function org-protocol-capture-html--to-clipboard
               :kill-client t))

(provide 'org-protocol-capture-to-clipboard)

;;; org-protocol-capture-to-clipboard.el ends here
