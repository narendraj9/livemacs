livemacs
========

Inspired by https://doitlive.readthedocs.io/en/latest/, this library provides
commands that let you replay text in the current buffer. 

```elisp
(use-package livemacs
  :commands livemacs-begin
  :load-path "/path/to/livemacs/")
```

To see it in action, switch to the buffer that you want to replay.

```
M-x livemacs-begin
```

To customize expansion/reduction of the visible portion of text in buffer as
you press keys, set `livemacs-next-position` and `livemacs-prev-position`.
To customize the keymap used while replaying text, set
`livemacs-transient-map`.



