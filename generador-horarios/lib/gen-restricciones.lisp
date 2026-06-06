;; === gen-restricciones.lisp — Generación de funciones Python para restricciones ===
;; Genera las funciones Python que cuentan incumplimientos de restricciones:
;;   tipo-restriccion, comentario-restriccion
;;   generar-cuerpo-nppq-tdpq, generar-cuerpo-tqpq-sbqp
;;   generar-funcion-restriccion
;;
;; Tipos de cuantificador soportados:
;;   nppq / tqpq  → restricciones simples  (duras,  PESO_DURA)
;;   tdpq / sbqp  → restricciones débiles  (blandas, PESO_BLANDA)
;;   minimizar / maximizar → objetivos de optimización (blandas)

(defun tipo-restriccion (nodo)
  (typecase nodo
    (nppq      :nppq)
    (tqpq      :tqpq)
    (tdpq      :tdpq)
    (sbqp      :sbqp)
    (minimizar :minimizar)
    (maximizar :maximizar)
    (t         :desconocido)))

(defun comentario-restriccion (tipo)
  (case tipo
    (:nppq      "SIMPLE / DURA  (nppq) — No Puede Pasar Que")
    (:tqpq      "SIMPLE / DURA  (tqpq) — Todo Que Pasa Que")
    (:tdpq      "DEBIL  / BLANDA (tdpq) — Todos Deben Pasar Que")
    (:sbqp      "DEBIL  / BLANDA (sbqp) — Solo Bien Para Que")
    (:minimizar "OPTIMIZACIÓN — Minimizar")
    (:maximizar "OPTIMIZACIÓN — Maximizar")
    (t          "RESTRICCIÓN DESCONOCIDA")))

(defun generar-cuerpo-nppq-tdpq (comprobacion stream)
  "Emite el cuerpo de una restricción nppq o tdpq."
  (typecase comprobacion
    ;; (op-mayor consulta 0) → devuelve directamente el conteo de la consulta
    (op-mayor
     (let ((izq (slot-value comprobacion 'operando-izq)))
       (typecase izq
         (consulta-simple
          (format stream "~areturn ~a~%~%"
                  (py-indent 1) (expr->py izq)))
         (t
          (format stream "~areturn 1 if ~a else 0~%~%"
                  (py-indent 1) (expr->py comprobacion))))))
    ;; Expresión booleana directa
    (t
     (format stream "~areturn 1 if ~a else 0~%~%"
             (py-indent 1) (expr->py comprobacion)))))

(defun generar-cuerpo-tqpq-sbqp (comprobacion stream)
  "Emite el cuerpo de una restricción tqpq o sbqp."
  (format stream "~areturn 0 if ~a else 1~%~%"
          (py-indent 1) (expr->py comprobacion)))

(defun generar-funcion-restriccion (nombre nodo stream)
  "Emite la función Python que cuenta cuántas veces se incumple la restricción."
  (let* ((tipo         (tipo-restriccion nodo))
         (comprobacion (slot-value nodo 'comprobacion))
         (elemento     (slot-value nodo 'elemento))
         (fn-nombre    (py-nombre nombre)))

    (format stream "# ~a~%" (comentario-restriccion tipo))
    (format stream "def ~a(horario):~%" fn-nombre)

    (case tipo
      ;; ── Simples / duras ──────────────────────────────────────────────
      (:nppq (generar-cuerpo-nppq-tdpq comprobacion stream))
      (:tqpq (generar-cuerpo-tqpq-sbqp comprobacion stream))

      ;; ── Débiles / blandas ────────────────────────────────────────────
      (:tdpq (generar-cuerpo-nppq-tdpq comprobacion stream))
      (:sbqp (generar-cuerpo-tqpq-sbqp comprobacion stream))

      ;; ── Minimizar: devuelve el máximo valor de la consulta en el dominio
      (:minimizar
       (if (and comprobacion elemento)
           (let ((dom-py  (py-nombre (nombre-entidad elemento)))
                 (fn-call (format nil "~a(horario, x)" (nombre-consulta-py comprobacion))))
             (format stream "~avalores = [~a for x in horario.~a]~%"
                     (py-indent 1) fn-call dom-py)
             (format stream "~areturn max(valores) if valores else 0~%~%" (py-indent 1)))
           (format stream "~areturn 0  # minimizar sin comprobacion/elemento~%~%" (py-indent 1))))

      ;; ── Maximizar: para minimizar el costo se devuelve el negativo del mínimo
      (:maximizar
       (if (and comprobacion elemento)
           (let ((dom-py  (py-nombre (nombre-entidad elemento)))
                 (fn-call (format nil "~a(horario, x)" (nombre-consulta-py comprobacion))))
             (format stream "~avalores = [~a for x in horario.~a]~%"
                     (py-indent 1) fn-call dom-py)
             (format stream "~areturn -min(valores) if valores else 0~%~%" (py-indent 1)))
           (format stream "~areturn 0  # maximizar sin comprobacion/elemento~%~%" (py-indent 1))))

      (t
       (format stream "~araise NotImplementedError('tipo de restriccion desconocido')~%~%"
               (py-indent 1))))))
