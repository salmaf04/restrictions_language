;; === gen-consultas.lisp — Generación de funciones Python para consultas ===
;; Genera las funciones Python que evalúan consultas-simple del AST:
;;   recolectar-dominios, generar-funcion-consulta

(defun recolectar-dominios (nombres-consultas)
  "Devuelve todos los nombres de entidad usados como dominios en las consultas."
  (let ((dominios nil))
    (dolist (nombre nombres-consultas)
      (when (boundp nombre)
        (let ((nodo (symbol-value nombre)))
          (when (typep nodo 'consulta-simple)
            (dolist (dom (slot-value nodo 'dominio-iteracion))
              (pushnew (nombre-entidad dom) dominios))))))
    dominios))

(defun generar-funcion-consulta (nombre nodo stream)
  "Emite la función Python que evalúa una consulta-simple."
  (let* ((iter-vars  (slot-value nodo 'variable-iteracion))
         (iter-doms  (slot-value nodo 'dominio-iteracion))
         (args       (slot-value nodo 'args))
         (cond-nodo  (slot-value nodo 'comprobacion))
         (operacion  (slot-value nodo 'operacion))
         (fn-nombre  (py-nombre nombre))
         ;; Firma: horario[, arg1, arg2, ...]
         (py-args    (if args
                         (format nil "horario, ~{~a~^, ~}" (mapcar #'py-nombre args))
                         "horario"))
         (n-bucles   (length iter-vars))
         (ind-if     (py-indent (1+ n-bucles)))
         (ind-cuerpo (py-indent (+ 2 n-bucles))))

    (format stream "def ~a(~a):~%" fn-nombre py-args)

    ;; Variable acumuladora según operación
    (case operacion
      (contar-distintos-dias
       (format stream "~adias = set()~%" (py-indent 1)))
      (t
       (format stream "~acount = 0~%" (py-indent 1))))

    ;; Bucles for anidados — uno por cada (variable dominio)
    (loop for var in iter-vars
          for dom in iter-doms
          for i from 1
          do (format stream "~afor ~a in horario.~a:~%"
                     (py-indent i)
                     (py-nombre var)
                     (py-nombre (nombre-entidad dom))))

    ;; Condición (si existe)
    (when cond-nodo
      (format stream "~aif ~a:~%" ind-if (expr->py cond-nodo)))

    ;; Cuerpo del bucle según operación
    (case operacion
      ((contar suma)
       (format stream "~acount += 1~%" ind-cuerpo))
      (contar-distintos-dias
       ;; Agrupa por el atributo 'fecha' de la variable de iteración.
       ;; Si el atributo difiere en tu dominio, adapta esta línea.
       (format stream "~adias.add(~a.fecha)~%" ind-cuerpo
               (py-nombre (first iter-vars))))
      (t
       (format stream "~acount += 1  # operacion '~a' — adaptar si es necesario~%"
               ind-cuerpo (py-nombre operacion))))

    ;; Retorno
    (case operacion
      (contar-distintos-dias
       (format stream "~areturn len(dias)~%~%" (py-indent 1)))
      (t
       (format stream "~areturn count~%~%" (py-indent 1))))))
