;; === gen-ast-python.lisp — Traducción AST → expresión Python ===
;; Registro de consultas y traducción de nodos AST a strings Python:
;;   *reg-consultas*, registrar-consulta, nombre-consulta-py
;;   bin->py, expr->py

;; =====================================================================
;; REGISTRO: objeto consulta-simple → nombre Python de su función
;; =====================================================================

(defvar *reg-consultas* (make-hash-table)
  "Mapa: consulta-simple → string con el nombre Python de su función.")

(defun registrar-consulta (nombre-sym nodo)
  (setf (gethash nodo *reg-consultas*) (py-nombre nombre-sym)))

(defun nombre-consulta-py (nodo)
  (or (gethash nodo *reg-consultas*) "consulta_desconocida"))


;; =====================================================================
;; EXPRESIONES AST → EXPRESIÓN PYTHON
;; =====================================================================

(defun bin->py (nodo op)
  "Genera expresión binaria infija."
  (format nil "(~a ~a ~a)"
          (expr->py (slot-value nodo 'operando-izq))
          op
          (expr->py (slot-value nodo 'operando-der))))

(defun expr->py (nodo)
  "Traduce un nodo AST a una expresión Python como string."
  (typecase nodo
    (null    "None")
    (symbol  (py-nombre nodo))
    (number  (format nil "~a" nodo))
    (string  (format nil "~s" nodo))

    ;; Acceso encadenado: ent.attr  (p. ej. asig.tribunal.tutor)
    (acceso-a-atributo-de-entidad
     (format nil "~a.~a"
             (expr->py (slot-value nodo 'entidad))
             (py-nombre (slot-value nodo 'atributo))))

    ;; Comparaciones
    (op-igual       (bin->py nodo "=="))
    (op-distinto    (bin->py nodo "!="))
    (op-mayor       (bin->py nodo ">"))
    (op-menor       (bin->py nodo "<"))
    (op-mayor-igual (bin->py nodo ">="))
    (op-menor-igual (bin->py nodo "<="))

    ;; Lógicas — se aplanan para evitar anidamiento innecesario
    (op-and (format nil "(~{~a~^ and ~})" (mapcar #'expr->py (flatten-op nodo 'op-and))))
    (op-or  (format nil "(~{~a~^ or ~})"  (mapcar #'expr->py (flatten-op nodo 'op-or))))
    (op-not (format nil "(not ~a)" (expr->py (slot-value nodo 'operando))))

    ;; Aritméticas
    (op-suma           (bin->py nodo "+"))
    (op-resta          (bin->py nodo "-"))
    (op-multiplicacion (bin->py nodo "*"))
    (op-division       (bin->py nodo "/"))

    ;; Referencia a una consulta-simple → llamada a su función Python
    (consulta-simple
     (let* ((args  (slot-value nodo 'args))
            (extra (if args
                       (format nil ", ~{~a~^, ~}" (mapcar #'py-nombre args))
                       "")))
       (format nil "~a(horario~a)" (nombre-consulta-py nodo) extra)))

    (t (format nil "# NODO_DESCONOCIDO<~a>" (class-name (class-of nodo))))))
