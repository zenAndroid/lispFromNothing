;; I am basically making this file to "translate" the code in the book.

;; To make the names of the funtions and of the arguments clearer.

;; This interpreter/compiler will be extended to support LAMBDA EXPRESSIONS (Lexprs)

;; Also adding support for the PROGN form.

;; In addition there will be a few new special for ms that will be used
;; inter nally to implement the LISP system in LISP:
;; *READC *WRITEC
;; *CAR *CDR *RPLACA *RPLACD
;; *ATOMP *SETAT OM
;; *NEXT *POOL
;; *HALT

;; I will rename these to more appropriate and understandable names.

;; *READCHAR *WRITECHAR
;; *CAR
;; *CDR
;; *REPLACE-CAR
;; *REPLACE-CDR
;; *ATOM-TAG-P *SETATOMTAG

      ;; The *ATOM-TAG-P function finds out if a cell (see below) has its atom
      ;; tag set. This does not mean that the cell is a LISP atom, though—
      ;; the atom tag is a much more low-level concept that will be
      ;; explained in detail in the next section. The *SETATOMTAG function
      ;; can be used to set or clear the atom tag of a cell. It is mostly used
      ;; to create LISP atoms. Nothing stops LISP from being low-level!
      ;; Your imagination is the limit!

;; *NEXT *POOL

      ;; The *POOL variable points to the cell pool, i.e. the memory pool
      ;; from which conses and atoms will be allocated. *NEXT is a
      ;; function that, given a cell, returns the address of the next cell in
      ;; the pool.

;; *HALT


;; The symbol list is a list containing all atoms (symbols) that are
;; known to the LISP system. It is the mechanism that gives identity
;; to atoms. Whenever the reader reads an atom, it looks it up in the
;; symbol list and if the symbol already is in the list, it will return the
;; symbol in the list instead of the one just read. When the symbol is
;; not in the list, it will add it first. Because the reader always retur ns
;; the same member of the symbol list when reading a symbol
;; consisting of the same characters, symbols are equal in the sense
;; of EQ.

(SETQ *SYMBOL-LIST (*NEXT (*NEXT *POOL))

(SETQ *FUNTAG (*NEXT (*NEXT (*NEXT (*NEXT (*NEXT (*NEXT *SYMLIS))))))

These are peudo-strings I think.

(SETQ *LP "(" LEFT PAREN
(SETQ *RP ")" RIGHT PAREN
(SETQ *NL "
") ; NEWLINE


The next PRO-GAMER move is to allows the "primitive" special operators to be passed as arguments
to higher-level functions:

(SETQ ATOM (LAMBDA (X) (ATOM X)))
(SETQ CAR (LAMBDA (X) (CAR X)))
(SETQ CDR (LAMBDA (X) (CDR X)))
(SETQ CONS (LAMBDA (X Y) (CONS X Y)))
(SETQ EQ (LAMBDA (X Y) (EQ X Y)))
(SETQ HALT (LAMBDA (X) (*HALT X)))

I suppose this is inevitable ...

(SETQ CAAR (LAMBDA (X) (CAR (CAR X))))
(SETQ CADR (LAMBDA (X) (CAR (CDR X))))
(SETQ CDAR (LAMBDA (X) (CDR (CAR X))))
(SETQ CDDR (LAMBDA (X) (CDR (CDR X))))

[Redacted the three letter ones tbh]

(SETQ LIST (LAMBDA X X)) ; This is because of including the Lexprs as a feature of the lang.

[What comes next is pretty standard]

(SETQ NULL (LAMBDA (X) (EQ X NIL)))
(SETQ NOT NULL)

(SETQ REPLACE-CAR (LAMBDA (X Y)
                          (IF (ATOM X)
                              (HALT "REPLACE-CAR: EXPECTED CONS")
                              (*REPLACE-CAR X Y)))))

(SETQ REPLACE-CDR (LAMBDA (X Y)
                          (IF (ATOM X)
                              (HALT "REPLACE-CDR: EXPECTED CONS")
                              (*REPLACE-CDR X Y))))


(SETQ REVCONC (LAMBDA (A B)
                     (IF (EQ A NIL)
                         B
                         (REVCONC (CDR A) (CONS (CAR A) B)))))

(SETQ REVERSE (LAMBDA (A)
                      (REVCONC A NIL)))

(SETQ NREVERSE (LAMBDA (A)
                       (LABEL ((NRECONC
                                (LAMBDA (A B)
                                        (COND ((EQ A NIL) B)
                                              (T (SETQ *TMP (CDR A))
                                                 (*REPLACE-CDR A B)
                                                 (NRECONC *TMP A))))))
                              (COND ((EQ A NIL) NIL)
                                    ((ATOM A)   (HALT "NREVERSE: EXPECTED LIST"))
                                    (T          (NRECONC A NIL))))))
