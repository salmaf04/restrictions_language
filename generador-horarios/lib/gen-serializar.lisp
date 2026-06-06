;; === gen-serializar.lisp — Serialización de instancias CLOS a Python ===
;; Convierte instancias CLOS del dominio a expresiones Python:
;;   entidad-de-clase, instancia->py, instancias-de, emitir-lista-py

(defun entidad-de-clase (clase-sym)
  "REF-ESPECIFICA-A-PROFESOR → PROFESOR (símbolo)."
  (let* ((str     (symbol-name clase-sym))
         (prefijo "REF-ESPECIFICA-A-"))
    (when (and (>= (length str) (length prefijo))
               (string= (subseq str 0 (length prefijo)) prefijo))
      (intern (subseq str (length prefijo))))))

(defun instancia->py (val)
  "Serializa un valor de slot a una expresión Python."
  (typecase val
    (null   "None")
    (string (format nil "~s" val))
    (number (format nil "~a" val))
    (symbol (py-nombre val))
    (ref-especifica-ent
     (let* ((clase     (class-name (class-of val)))
            (ent-nom   (entidad-de-clase clase))
            (slots-lst (when ent-nom (gethash ent-nom *slots-de-entidad*)))
            (clase-py  (if ent-nom
                           (string-capitalize (py-nombre ent-nom))
                           (string-capitalize (py-nombre clase))))
            (args      (loop for s in slots-lst
                             when (slot-boundp val s)
                             collect (format nil "~a=~a"
                                             (py-nombre s)
                                             (instancia->py (slot-value val s))))))
       (format nil "~a(~{~a~^, ~})" clase-py args)))
    (t (format nil "# desconocido: ~a" val))))

(defun instancias-de (entidad-nombre)
  "Devuelve la lista de valores (no símbolos) de las instancias de una entidad."
  (mapcar #'symbol-value
          (gethash entidad-nombre *instancias-de-entidad*)))

(defun emitir-lista-py (nombre-var entidad-nombre stream indent)
  "Emite  nombre_var = [Entidad(...), ...]  con las instancias registradas."
  (let ((insts (instancias-de entidad-nombre)))
    (if insts
        (progn
          (format stream "~a~a = [~%" indent nombre-var)
          (dolist (inst insts)
            (format stream "~a    ~a,~%" indent (instancia->py inst)))
          (format stream "~a]~%" indent))
        (format stream "~a~a = []  # sin instancias definidas~%"
                indent nombre-var))))
