
;;; mode-icons.el --- Show icons for modes -*- lexical-binding: t; -*-

;; Copyright (C) 2013  Tom Willemse

;; Author: Tom Willemse <tom@ryuslash.org>
;; Keywords: multimedia
;; Version: 0.1.0
;; URL: http://ryuslash.org/projects/mode-icons.html

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defconst mode-icons--directory
  (if load-file-name
      (file-name-directory load-file-name)
    default-directory)
  "Where mode-icons was loaded from.")

(defun mode-icons-get-icon-file (icon)
  "Get the location of ICON.

ICON should be a file name with extension.  The result is the
absolute path to ICON."
  (concat mode-icons--directory "/icons/" icon))

(defvar mode-icons
  `(
    ("CSS" "css" xpm)
    ("Coffee" "coffee" xpm)
    ("Compilation" "compile" xpm)
    ("Emacs-Lisp" "emacs" xpm)
    ("HTML" "html" xpm)
    ("Haml" "haml" xpm)
    ("Image[imagemagick]" "svg" xpm)
    ("Inf-Ruby" "infruby" xpm)
    ("JavaScript" "js" xpm)
    ("Lisp" "cl" xpm)
    ("nXML" "xml" xpm)
    ("Org" "org" xpm)
    ("PHP" "php" xpm)
    ("Projectile Rails Server" "rails" xpm)
    ("Python" "python" xpm)
    ("Ruby" "ruby" xpm)
    ("ESS[S]" "R" xpm)
    ("iESS" "R" xpm)
    ("SCSS" "sass" xpm)
    ("Sass" "sass" xpm)
    ("Scheme" "scheme" xpm)
    ("Shell-script" "bash" xpm)
    ("Slim" "slim" xpm)
    ("Term" "term" xpm)
    ("Web" "html" xpm)
    ("XML" "xml" xpm)
    ("YAML" "yaml" xpm)
    ("YASnippet" "yas" xpm)
    (" yas" "yas" xpm)
    )
  "Icons for major and minor modes.

Each specification is a list with the first element being the
name of the major mode.  The second the name of the icon file,
without the extension.  And the third being the type of icon.")

(defun mode-icons-get-icon-display (icon type)
  "Get the value for the display property of ICON having TYPE.

ICON should be a string naming the file of the icon, without its
extension.  Type should be a symbol designating the file type for
the icon."
  (let ((icon-path (mode-icons-get-icon-file
                    (concat icon "." (symbol-name type)))))
   `(image :type ,type :file ,icon-path :ascent center)))

(defun mode-icons-propertize-mode (mode icon-spec)
  "Propertize MODE with ICON-SPEC.

MODE should be a string, the name of the mode to propertize.
ICON-SPEC should be a specification from `mode-icons'."
  (propertize
   mode 'display (mode-icons-get-icon-display (nth 1 icon-spec) (nth 2 icon-spec))))

(defun mode-icons-get-mode-icon (mode)
  "Get the icon for MODE, if there is one."
  (let* ((mode-name (format-mode-line mode))
         (icon-spec (assoc mode-name mode-icons)))
    (if icon-spec
        (mode-icons-propertize-mode mode-name icon-spec)
      mode-name)))

(defun mode-icons-set-mode-icon (mode)
  "Set the icon for MODE."
  (setq mode-name (mode-icons-get-mode-icon mode)))

(defun mode-icons-set-current-mode-icon ()
  "Set the icon for the current major mode."
  (mode-icons-set-mode-icon mode-name))

(defvar mode-icons-set-minor-mode-icon-alist nil)

(defun mode-icons-set-minor-mode-icon-undo ()
  (let (minor)
    (dolist (mode mode-icons-set-minor-mode-icon-alist)
      (setq minor (assq (car mode) minor-mode-alist))
      (when minor
	(setcdr minor (cdr mode)))))
  (setq mode-icons-set-minor-mode-icon-alist nil))

(defun mode-icons-set-minor-mode-icon ()
  "Set the icon for the minor modes."
  (let (icon-spec mode-name minor)
    (dolist (mode minor-mode-alist)
      (unless (assq (car mode) mode-icons-set-minor-mode-icon-alist)
	(setq mode-name (format-mode-line mode)
	      icon-spec (assoc mode-name mode-icons))
	(when icon-spec
	  (setq minor (assq (car mode) minor-mode-alist))
	  (when minor
	    (or (assq (car mode) mode-icons-set-minor-mode-icon-alist)
		(push (copy-sequence minor) mode-icons-set-minor-mode-icon-alist))
	    (setq mode-name (replace-regexp-in-string "^ " "" mode-name))
	    (setcdr minor (list (concat " " (mode-icons-propertize-mode mode-name icon-spec))))))))))

;;;###autoload
(define-minor-mode mode-icons-mode
  "Replace the name of the current major mode with an icon."
  :global t
  (if mode-icons-mode
      (progn
        (add-hook 'after-change-major-mode-hook 'mode-icons-set-current-mode-icon)
	(add-hook 'after-change-major-mode-hook 'mode-icons-set-minor-mode-icon)
	(mode-icons-set-minor-mode-icon)
        (mode-icons-set-current-mode-icon))
    (remove-hook 'after-change-major-mode-hook 'mode-icons-set-minor-mode-icon)
    (remove-hook 'after-change-major-mode-hook 'mode-icons-set-current-mode-icon)
    (mode-icons-set-minor-mode-icon-undo)))

(provide 'mode-icons)
;;; mode-icons.el ends here
