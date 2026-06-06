;; === gen-ast-math.lisp — Traducción AST → notación matemática ===
;; Registro inverso de consultas y traducción de nodos AST a notación matemática:
;;   *consultas-por-nombre*
;;   bin->math, expr->math
;;   consulta->math-str, restriccion->math-str, consultas-en-restriccion

;; Registro inverso: nombre-python → nodo consulta-simple
(defvar *consultas-por-nombre* (make-hash-table :test #'equal))

(defun bin->math (nodo op)
  (format nil "(~a~a~a)"
          (expr->math (slot-value nodo 'operando-izq))
          op
          (expr->math (slot-value nodo 'operando-der))))

(defun expr->math (nodo)
  "Traduce un nodo AST a notación matemática como string."
  (typecase nodo
    (null    "∅")
    (symbol  (math-nombre nodo))
    (number  (format nil "~a" nodo))
    (string  (format nil "\"~a\"" nodo))

    (acceso-a-atributo-de-entidad
     (format nil "~a(~a)"
             (math-nombre (slot-value nodo 'atributo))
             (expr->math  (slot-value nodo 'entidad))))

    (op-igual       (bin->math nodo " = "))
    (op-distinto    (bin->math nodo " ≠ "))
    (op-mayor       (bin->math nodo " > "))
    (op-menor       (bin->math nodo " < "))
    (op-mayor-igual (bin->math nodo " ≥ "))
    (op-menor-igual (bin->math nodo " ≤ "))
    (op-suma        (bin->math nodo " + "))
    (op-resta       (bin->math nodo " - "))
    (op-multiplicacion (bin->math nodo " · "))
    (op-division    (bin->math nodo " / "))

    (op-and (format nil "(~{~a~^ ∧ ~})"
                    (mapcar #'expr->math (flatten-op nodo 'op-and))))
    (op-or  (format nil "(~{~a~^ ∨ ~})"
                    (mapcar #'expr->math (flatten-op nodo 'op-or))))
    (op-not (format nil "¬~a" (expr->math (slot-value nodo 'operando))))

    ;; consulta-simple → llamada funcional
    (consulta-simple
     (let* ((args  (slot-value nodo 'args))
            (fn    (nombre-consulta-py nodo))
            (extra (if args
                       (format nil ", ~{~a~^, ~}" (mapcar #'math-nombre args))
                       "")))
       (format nil "~a(h~a)" fn extra)))

    (t "?")))

(defun consulta->math-str (nombre-str nodo)
  "Genera la definición matemática de una consulta-simple."
  (let* ((iter-vars  (slot-value nodo 'variable-iteracion))
         (iter-doms  (slot-value nodo 'dominio-iteracion))
         (cond-nodo  (slot-value nodo 'comprobacion))
         (operacion  (slot-value nodo 'operacion))
         (args       (slot-value nodo 'args))
         (fn-sig     (if args
                         (format nil "~a(h, ~{~a~^, ~})"
                                 nombre-str (mapcar #'math-nombre args))
                         (format nil "~a(h)" nombre-str)))
         (iter-strs  (mapcar (lambda (v d)
                               (format nil "~a∈~a"
                                       (math-nombre v)
                                       (string-upcase (py-nombre (nombre-entidad d)))))
                             iter-vars iter-doms))
         (idx        (format nil "~{~a~^, ~}" iter-strs)))
    (case operacion
      ((suma contar)
       (format nil "~a = Σ_{~a}  [~a]" fn-sig idx (expr->math cond-nodo)))
      (contar-distintos-dias
       (format nil "~a = |{ fecha(~a) : ~{~a~^, ~},  ~a }|"
               fn-sig (math-nombre (first iter-vars))
               iter-strs (expr->math cond-nodo)))
      (t
       (format nil "~a = Σ_{~a}  [~a]" fn-sig idx (expr->math cond-nodo))))))

(defun restriccion->math-str (nodo)
  "Genera la expresión matemática de la restricción (sin índice)."
  (let* ((tipo         (tipo-restriccion nodo))
         (comprobacion (slot-value nodo 'comprobacion))
         (elemento     (slot-value nodo 'elemento)))
    (case tipo
      (:nppq
       (typecase comprobacion
         (op-mayor
          (let ((izq (slot-value comprobacion 'operando-izq)))
            (typecase izq
              (consulta-simple
               (format nil "~a(h) = 0" (nombre-consulta-py izq)))
              (t
               (format nil "¬( ~a )" (expr->math comprobacion))))))
         (t (format nil "¬( ~a )" (expr->math comprobacion)))))
      ((:tqpq :tdpq :sbqp)
       (expr->math comprobacion))
      (:minimizar
       (when (and comprobacion elemento)
         (format nil "minimizar  max_{{x ∈ ~a}}  ~a(h, x)"
                 (string-upcase (py-nombre (nombre-entidad elemento)))
                 (nombre-consulta-py comprobacion))))
      (:maximizar
       (when (and comprobacion elemento)
         (format nil "maximizar  min_{{x ∈ ~a}}  ~a(h, x)"
                 (string-upcase (py-nombre (nombre-entidad elemento)))
                 (nombre-consulta-py comprobacion))))
      (t "?"))))

(defun consultas-en-restriccion (nodo)
  "Devuelve lista de consulta-simple directamente referenciados en la restricción."
  (let ((resultado nil))
    (labels ((buscar (n)
               (typecase n
                 (consulta-simple
                  (pushnew n resultado))
                 (op-mayor
                  (buscar (slot-value n 'operando-izq))
                  (buscar (slot-value n 'operando-der)))
                 (op-and (dolist (x (flatten-op n 'op-and)) (buscar x)))
                 (op-or  (dolist (x (flatten-op n 'op-or))  (buscar x)))
                 (op-not (buscar (slot-value n 'operando)))
                 (t nil))))
      (when (typep nodo 'cuantificador-restriccion)
        (buscar (slot-value nodo 'comprobacion))))
    resultado))
