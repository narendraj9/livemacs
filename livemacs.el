;;; livemacs.el --- Live presentations inspired by project doitlive  -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Narendra Joshi

;; Author: Narendra Joshi <narendraj9@gmail.com>
;; Keywords: convenience, data

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Inspired by https://github.com/sloria/doitlive
;; While in a buffer with code or text, call `livemacs-replay' and type like a
;; madman.  Relies on `buffer-invisibility-spec' feature for hiding/showing text
;; in buffer.  See (info "(elisp) Invisible Text").

;;; Code:
(defgroup livemacs nil
  "Group for customization related to livemacs.el.")

(defcustom livemacs-next-position (lambda (p) (+ (random 5) p))
  "Function to compute the next position up to which buffer is made visible.
Calling (livemacs-advance-point livemacs-buffer-position) should
return the next value for `livemacs-buffer-position'."
  :group 'livemacs
  :type 'function)

(defcustom livemacs-prev-position (lambda (p) (- p (random 5)))
  "Function called to regress visible point.
See `livemacs-next-position'."
  :group 'livemacs
  :type 'functionl)

(defvar-local livemacs-buffer-position 1
  "Starting position for invisible text in replaying buffer.")

(defvar-local livemacs-exitfun nil
  "Function to exit livemacs.")

(defcustom livemacs-transient-map
  (let ((map (make-sparse-keymap)))
    (mapc (lambda (k)
            (define-key map k #'livemacs-advance))
          (append [[tab] [space] [return]]
                  (mapcar #'char-to-string (number-sequence ?A ?z))))
    (define-key map [backspace] #'livemacs-regress)
    (define-key map (kbd "C-c C-c") #'livemacs-stop)
    map)
  "Keymap used in a `livemacs' buffer.
Default bindings setup all ASCII chars to be used for advancing
visible text.  Also binds <return>, <space> and <tab> for convenience.
Binds \[livemacs-regress] to `livemacs-regress'.
Binds \[livemacs-stop] to `livemacs-stop'."
  :type 'keymap
  :group 'livemacs)

(defun livemacs-hide-text (beg end)
  "Hide text in region [BEG, END)."
  (put-text-property beg end 'invisible t))

(defun livemacs-show-text (beg end)
  "Show text in region [BEG, END)."
  (put-text-property beg end 'invisible nil))

(defun livemacs-advance ()
  "Advances the visible territory of text in current buffer."
  (interactive)
  (let ((next-buf-pos (min (funcall livemacs-next-position
                                    livemacs-buffer-position)
                           (point-max))))
    (livemacs-show-text livemacs-buffer-position next-buf-pos)
    (setq livemacs-buffer-position next-buf-pos)
    (goto-char livemacs-buffer-position)))

(defun livemacs-regress ()
  "Move back hiding text that was shown earlier in buffer."
  (interactive)
  (let ((prev-buf-pos (max (funcall livemacs-prev-position
                                    livemacs-buffer-position)
                           1)))
    (livemacs-hide-text prev-buf-pos livemacs-buffer-position)
    (setq livemacs-buffer-position prev-buf-pos)
    (goto-char livemacs-buffer-position)))

(defun livemacs-reset ()
  "Reset `livemacs' maintained state in current buffer."
  (livemacs-show-text (point-min) (point-max))
  (setq livemacs-buffer-position 1)
  (setq livemacs-exitfun nil))

(defun livemacs-begin ()
  "Replay text visible in current buffer when `livemacs-keys' are pressed.
Replaying is stopped when any key other than those specified in
`livemacs-keys' is pressed."
  (interactive)
  (setq livemacs-exitfun
        (set-transient-map livemacs-transient-map t #'livemacs-reset))
  (livemacs-hide-text (point-min) (point-max))
  (message "Started livemacs!"))

(defun livemacs-stop ()
  "Stop `livemacs' and reset buffer local state."
  (interactive)
  (when livemacs-exitfun
    (funcall livemacs-exitfun))
  (livemacs-reset)
  (message "Stopped livemacs!"))

(provide 'livemacs)
;;; livemacs.el ends here
