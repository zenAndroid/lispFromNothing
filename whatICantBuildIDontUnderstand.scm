I am basically making this file to "translate" the code in the book.

To make the names of the funtions and of the arguments clearer.

This interpreter/compiler will be extended to support LAMBDA EXPRESSIONS (Lexprs)

Also adding support for the PROGN form.

In addition there will be a few new special for ms that will be used
inter nally to implement the LISP system in LISP:
*READC *WRITEC
*CAR *CDR *RPLACA *RPLACD
*ATOMP *SETAT OM
*NEXT *POOL
*HALT

I will rename these to more appropriate and understandable names.

*READCHAR *WRITECHAR
*CAR
*CDR
*REPLACE-CAR
*REPLACE-CDR
*ATOM-TAG-P *SETATOMTAG

      The *ATOM-TAG-P function finds out if a cell (see below) has its atom
      tag set. This does not mean that the cell is a LISP atom, though—
      the atom tag is a much more low-level concept that will be
      explained in detail in the next section. The *SETATOMTAG function
      can be used to set or clear the atom tag of a cell. It is mostly used
      to create LISP atoms. Nothing stops LISP from being low-level!
      Your imagination is the limit!

*NEXT *POOL

      The *POOL variable points to the cell pool, i.e. the memory pool
      from which conses and atoms will be allocated. *NEXT is a
      function that, given a cell, returns the address of the next cell in
      the pool.

*HALT


The symbol list is a list containing all atoms (symbols) that are
known to the LISP system. It is the mechanism that gives identity
to atoms. Whenever the reader reads an atom, it looks it up in the
symbol list and if the symbol already is in the list, it will return the
symbol in the list instead of the one just read. When the symbol is
not in the list, it will add it first. Because the reader always retur ns
the same member of the symbol list when reading a symbol
consisting of the same characters, symbols are equal in the sense
of EQ.

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

(SETQ LIST (LAMBDA ARGLIST ARGLIST)) ; This is because of including the Lexprs as a feature of the lang.

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


;; (define (revconc a b) (if (eq? a '()) b (revconc (cdr a) (cons (car a) b))))
;; > (revconc '(1 2 3) '(7 8 9))
;; (3 2 1 7 8 9)
;; > (trace revconc)
;; (revconc)
;; > (revconc '(1 2 3) '(7 8 9))
;; |(revconc (1 2 3) (7 8 9))
;; |(revconc (2 3) (1 7 8 9))
;; |(revconc (3) (2 1 7 8 9))
;; |(revconc () (3 2 1 7 8 9))
;; |(3 2 1 7 8 9)
;; (3 2 1 7 8 9)
;; > (define (reverse a) (revconc a '()))
;; > (reverse '(1 2 3))
;; |(revconc (1 2 3) ())
;; |(revconc (2 3) (1))
;; |(revconc (3) (2 1))
;; |(revconc () (3 2 1))
;; |(3 2 1)
;; (3 2 1)
;; > (trace revconc reverse)
;; (revconc reverse)
;; > (reverse '(1 2 3))
;; |(reverse (1 2 3))
;; |(revconc (1 2 3) ())
;; |(revconc (2 3) (1))
;; |(revconc (3) (2 1))
;; |(revconc () (3 2 1))
;; |(3 2 1)
;; (3 2 1)

(SETQ NREVERSE (LAMBDA (A)
                       (LABEL ((NREVCONC
                                (LAMBDA (A B)
                                        (COND ((EQ A NIL) B)
                                              (T (SETQ *TMP (CDR A))
                                                 (*REPLACE-CDR A B)
                                                 (NREVCONC *TMP A))))))
                              (COND ((EQ A NIL) NIL)
                                    ((ATOM A)   (HALT "NREVERSE: EXPECTED LIST"))
                                    (T          (NREVCONC A NIL))))))

(SETQ APPEND (LAMBDA (A B)
                     (REVCONC (REVERSE A) B)))

(SETQ NCONC (LAMBDA (A B)
                    (LABEL
                     ((LOOP (LAMBDA (A B)
                                    (COND ((ATOM (CDR A)) (REPLACE-CDR A B))
                                          (T              (NCONC (CDR A) B))))))
                     (COND ((ATOM A) B)
                           (T (LOOP A B)
                              A)))))

(SETQ EQUAL (LAMBDA (A B)
                    (COND ((EQ A B))
                          ((ATOM A)                NIL)
                          ((ATOM B)                NIL)
                          ((EQUAL (CAR A) (CAR B)) (EQUAL (CDR A) (CDR B))))))

Works the same as the same as the classic one.

;; (member 'koo '(joo hoo ioo koo loo poo coo))
;; (koo loo poo coo)
(SETQ MEMBER (LAMBDA (X A)
                     (COND ((EQ A NIL) NIL)
                           ((EQUAL X (CAR A)) A)
                           (T (MEMBER X (CDR A))))))

;; (assoc 'k '((k . kk)))
;; (k . kk)
;; > (assoc 'k '((k . kk) (kkkj . joihou)))
;; (k . kk)
;; > (assoc 'kkkj '((k . kk) (kkkj . joihou)))
;; (kkkj . joihou)

Also works with lists.

(SETQ ASSOC (LAMBDA (X A)
                    (COND ((EQ A NIL) NIL)
                          ((EQUAL X (CAAR A)) (CAR A))
                          (T (ASSOC X (CDR A))))))

;; In case you wonder about the funny var iable names, like *F: they
;; are used to avoid the downward FUNARG problem (page 189). A
;; leading ‘‘*’’ character should never appear in programs, except in
;; LISP system code and var iables of higher-order functions.

(SETQ MAPCAR (LAMBDA (*MAPPED-FUNCTION *ARRAY)
                     (LABEL
                      ((MAP (LAMBDA (A R)
                                    (COND ((EQ A NIL) (NREVERSE R))
                                          (T (MAP (CDR A)
                                                  (CONS (*MAPPED-FUNCTION (CAR A)) R)))))))
                      (MAP *ARRAY NIL))))

(SETQ MAPCAR2 (LAMBDA (*MAPPED-FUNCTION *ARRAY1 *ARRAY2)
                      (LABEL
                       ((MAP (LAMBDA (A B R)
                                     (COND ((EQ A NIL) (NREVERSE R))
                                           ((EQ B NIL) (NREVERSE R))
                                           (T          (MAP (CDR A)
                                                            (CDR B)
                                                            (CONS (*MAPPED-FUNCTION (CAR A) (CAR B))
                                                                  R)))))))
                       (MAP *ARRAY1 *ARRAY2 NIL))))

(SETQ REDUCE (LAMBDA (*F *B *A)
                     (LABEL
                      ((LOCAL-REDUCER (LAMBDA (A RESULT)
                                              (COND ((EQ A NIL) RESULT)
                                                    (T          (LOCAL-REDUCER (CDR A) (*F RESULT (CAR A))))))))
                      (LOCAL-REDUCER *A *B))))

(SETQ RREDUCE (LAMBDA (*F *B *A)
                      (LABEL
                       ((LOCAL-REDUCER (LAMBDA (A R)
                                               (COND ((EQ A NIL) R)
                                                     (T          (LOCAL-REDUCER (CDR A) (*F (CAR A) R)))))))
                       (LOCAL-REDUCER (REVERSE *A) *B))))

WRITEC will print the first character of its argument, if its
argument is an atom. There cannot be any type checking here,
because WRITEC can also print first characters of atom names,
which is something entirely different. Things get a bit messy here!
All the ugly details follow immediately.

(SETQ WRITECHAR (LAMBDA (C)
                     (*WRITEC C)))

(SETQ TERMINATE-PRINTER (LAMBDA () ; Original name: TERPRI (because lisp is retar-, lisp is the most powerful language in the world actually and people that sont like it just dont GET it ya kno)
                                (*WRITEC *NL)))

(SETQ PRINT-ITEM (LAMBDA (X) ; Original name PRIN1, for "print one"
                         (LABEL
                          ((PRINT-ATOM-NAME-CHARS (LAMBDA (X) ; Original name: PRC
                                                          (COND ((EQ X NIL))
                                                                (T (*WRITEC X)
                                                                   (PRINT-ATOM-NAME-CHARS (*CDR X))))))
                           (PRINT-ATOM (LAMBDA (X) ; Original name: PR-ATOM
                                               (PRINT-ATOM-NAME-CHARS (*CAR X))))
                           (PRINT-MEMBERS (LAMBDA (X) ; Original name: PRINT-MEMBERS
                                                  (COND ((EQ X NIL))
                                                        ((ATOM X)
                                                         (PR ". ")
                                                         (PR X))
                                                        ((EQ (CDR X) NIL)
                                                         (PR (CAR X)))
                                                        (T (PR (CAR X))
                                                           (PR " ")
                                                           (PRINT-MEMBERS (CDR X))))))
                           (PRINT-DELEGATE (LAMBDA (X) ; Original name: PR
                                                   (COND ((EQ X NIL)
                                                          (*WRITEC (QUOTE N))
                                                          (*WRITEC (QUOTE I))
                                                          (*WRITEC (QUOTE L)))
                                                         ((*ATOMP X)
                                                          (*WRITEC "<")
                                                          (*WRITEC X)
                                                          (*WRITEC ">"))
                                                         ((ATOM X)
                                                          (PRINT-ATOM X))
                                                         (T (*WRITEC *LP)
                                                            (PRINT-MEMBERS X)
                                                            (*WRITEC *RP))))))
                          (PRINT-DELEGATE X)
                          X)))

(SETQ PRINT (LAMBDA (X)
                    (PRINT-ITEM X)
                    (TERMINATE-PRINTER)
                    X))

The SAMENAMEP function expects two atom names, i.e. atoms with
their root cells removed, and returns T, if the chains of characters
of the two names match.

(SETQ SAMENAMEP (LAMBDA (X Y)
                        (COND ((EQ X NIL) (EQ Y NIL))
                              ((EQ Y NIL) NIL)
                              ((EQ (*CAR X) (*CAR Y))
                               (SAMENAMEP (*CDR X) (*CDR Y))))))

; REMINDER: Whenever you see *CAR or *CDR, remember they are the untyped versions.
; Specifically, refer to the figure in page 52 (FigureFour-p52)
; So the *CAR goes straight to the CHARACTER LIST that makes up the *NAME* of a given ATOM.

(SETQ INTERN (LAMBDA (ARG-SYM) ; Interns symbols and itroduces then to the symbol list, uses bucket list data structure.
                     (LABEL ((FIRST (LAMBDA (ARG) (CONS (MKNAME (*CAR ARG) NIL) NIL)))
                             ; FIRST := takes arg symbol; makes a list of an atomic cell named with the first char of the arg. (??? i think this is a good way of explaining it?)

                             (FIND  (LAMBDA (X SELECTOR A)
                                            (COND ((EQ A NIL)                               NIL)
                                                  ((SAMENAMEP (*CAR X) (*CAR (SELECTOR A))) (CAR A))
                                                  (T                                        (FIND X SELECTOR (CDR A))))))
                             ; FIND := X=SYMBOL SELECTOR=CAR/CAAR BUCKET/SUBLISTS=bucket list or a specific bucket
                             ; Traverses the bucket or the bucket list (depending on the selector; CAR=bucket LIST, CAAR=specific bucket)
                             (F (FIRST ARG-SYM))
                             (B (FIND F CAAR *SYMLIS)))
                            (COND (B (LABEL ((V (FIND ARG-SYM CAR (CDR B))))
                                            (COND (V)
                                                  (T (*REPLACE-CDR B (CONS ARG-SYM (CDR B)))
                                                     ARG-SYM))))
                                  (T (*REPLACE-CAR *SYMLIS (CONS (CONS F (LIST ARG-SYM))
                                                                 *SYMLIS))
                                     ARG-SYM)))))
;; OKAY FINALLU+Y I UNDERSTAND I THINK : *SYMLIST IS A LIST OF BUCKET-LISTS
;; WAIT actually maybe not rip, i think there is simply a mistake and instead of calling (car *symlis) the code should of been *symlist

(SETQ MKNAME (LAMBDA (C A)
                     (LABEL ((N (CONS NIL A)))
                            (*SETATOMTAG N T)
                            (*REPLACE-CAR N (*CAR C)))))
