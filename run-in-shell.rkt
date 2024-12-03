#lang racket

(require racket/system)

;; runs a command in the current shell and prints stdout and stderr as they are received 
(define (run-in-shell command)
    ;; Launch the subprocess
    (define-values (proc stdout stdin stderr)
      (subprocess #f #f #f "/bin/sh" "-c" command))

    ;; Function to forward output from a port to the terminal
    (define (forward-output input-port output-port)
      (thread
       (lambda ()
         (let loop ()
           (define line (read-line input-port 'any)) ; Read a line from the input port
           (unless (eof-object? line)               ; Stop if EOF is reached
             (write-string line output-port)       ; Write the line to the terminal
             (newline output-port)                 ; Add a newline
             (flush-output output-port)            ; Flush for immediate display
             (loop))))))                           ; Continue looping for more lines

    ;; Forward stdout and stderr to the terminal
    (define stdout-thread (forward-output stdout (current-output-port)))
    (define stderr-thread (forward-output stderr (current-error-port)))

    ;; Wait for the subprocess to complete
    (subprocess-wait proc)

    ;; Ensure all threads finish processing
    (thread-wait stdout-thread)
    (thread-wait stderr-thread))
