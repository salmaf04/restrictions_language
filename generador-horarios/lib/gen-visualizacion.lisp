;; === gen-visualizacion.lisp — Funciones mostrar_modelo y mostrar_resultado ===
;; Genera el código Python que imprime el modelo abstracto y el resultado:
;;   generar-str-entidad
;;   generar-mostrar-modelo
;;   generar-mostrar-resultado

;; =====================================================================
;; GENERADOR: __str__ para clases de entidad
;; =====================================================================

(defun generar-str-entidad (slots stream)
  "Emite el método __str__ según los slots disponibles."
  (cond
    ((member 'nombre slots)
     (format stream "    def __str__(self): return str(self.nombre)~%"))
    ((and (= (length slots) 1) (member 'id slots))
     (format stream "    def __str__(self): return str(self.id)~%"))
    ((= (length slots) 1)
     (format stream "    def __str__(self): return str(self.~a)~%" (py-nombre (first slots))))
    (slots
     ;; f-string con todos los slots abreviados
     (let ((parts (mapcar (lambda (s)
                            (format nil "~a={self.~a}" (py-nombre s) (py-nombre s)))
                          slots)))
       (format stream "    def __str__(self): return f'(~{~a~^, ~})'~%" parts)))))


;; =====================================================================
;; GENERADOR: mostrar_modelo  —  datos, variables, objetivo, restricciones
;;
;; id-const    — nombre de la constante Python de identidades, ej. "TRIBUNALES"
;; pool-consts — lista de constantes de pools, ej. ("POOL_FECHA" "POOL_MOMENTO" ...)
;; id-py       — nombre Python del slot identidad, ej. "tribunal"
;; vars-py     — lista de nombres Python de slots variables
;; otros-consts — constantes de otros dominios, ej. ("PROFESORES")
;; =====================================================================

(defun generar-mostrar-modelo (restricciones-duras restricciones-blandas
                               peso-dura peso-blanda
                               id-const pool-consts id-py vars-py otros-consts
                               stream)
  "Genera mostrar_modelo() con el modelo abstracto de optimización."
  ;; Letras para los conjuntos (primera letra en mayúscula)
  (let* ((T-set   (string-upcase (subseq id-py 0 1)))
         (var-sets (mapcar (lambda (v) (string-upcase (subseq v 0 1))) vars-py))
         (oth-sets (mapcar (lambda (c) (string-upcase (subseq (string-downcase c) 0 1)))
                           otros-consts)))

    (format stream "def mostrar_modelo():~%")
    (format stream "    \"\"\"Imprime el modelo abstracto de optimizacion.\"\"\"~%")
    (format stream "    sep = '=' * 60~%")
    (format stream "    print(sep)~%")
    (format stream "    print('MODELO DE OPTIMIZACION')~%")
    (format stream "    print(sep)~%")
    (format stream "    print()~%")

    ;; ── ÍNDICES Y CONJUNTOS ─────────────────────────────────────────
    (format stream "    print('INDICES Y CONJUNTOS:')~%")
    ;; Identidad
    (format stream "    print(f'  ~a  =  conjunto de ~as      (|~a| = {len(~a)})')~%"
            T-set id-py T-set id-const)
    ;; Variables
    (dolist (triple (mapcar #'list vars-py var-sets pool-consts))
      (let ((vpy (first triple)) (set (second triple)) (cst (third triple)))
        (format stream "    print(f'  ~a  =  conjunto de ~a disponibles   (|~a| = {len(~a)})')~%"
                set vpy set cst)))
    ;; Otros
    (dolist (triple (mapcar #'list
                            (mapcar #'string-downcase otros-consts)
                            oth-sets
                            otros-consts))
      (let ((nombre (first triple)) (set (second triple)) (cst (third triple)))
        (format stream "    print(f'  ~a  =  conjunto de ~a   (|~a| = {len(~a)})')~%"
                set nombre set cst)))
    (format stream "    print()~%")

    ;; ── VARIABLES DE DECISIÓN ────────────────────────────────────────
    (format stream "    print('VARIABLES DE DECISION:')~%")
    (format stream "    print('  Para cada ~a t ∈ ~a se asigna:')~%" id-py T-set)
    (dolist (triple (mapcar #'list vars-py var-sets vars-py))
      (let ((vpy (first triple)) (set (second triple)))
        (format stream "    print('    ~a_t ∈ ~a   (~a)')~%" vpy set vpy)))
    (format stream "    print()~%")

    ;; ── FUNCIÓN OBJETIVO ─────────────────────────────────────────────
    (format stream "    print('FUNCION OBJETIVO:')~%")
    (format stream "    print('  minimizar z(h) donde:')~%")
    (format stream "    print('    z(h) = ~a · Σ_i incumpl_i(h)   [duras]')~%" peso-dura)
    (format stream "    print('         + ~a · Σ_j incumpl_j(h)   [blandas]')~%" peso-blanda)
    (format stream "    print()~%")

    ;; ── RESTRICCIONES DURAS ──────────────────────────────────────────
    (when restricciones-duras
      (format stream "    print('RESTRICCIONES DURAS  (nppq / tqpq):')~%")
      (loop for nombre in restricciones-duras
            for i from 1
            do (let* ((nodo     (symbol-value nombre))
                      (tipo-str (comentario-restriccion (tipo-restriccion nodo)))
                      (math-str (restriccion->math-str nodo))
                      (q-refs   (consultas-en-restriccion nodo)))
                 (format stream "    print('  R~a  [~a]:')~%" i tipo-str)
                 (format stream "    print('    ~a')~%" math-str)
                 (when q-refs
                   (format stream "    print('    donde:')~%")
                   (dolist (q q-refs)
                     (let* ((q-nombre (nombre-consulta-py q))
                            (q-nodo   (gethash q-nombre *consultas-por-nombre*)))
                       (when q-nodo
                         (format stream "    print('      ~a')~%"
                                 (consulta->math-str q-nombre q-nodo))))))
                 (format stream "    print()~%")))
      (format stream "    print()~%"))

    ;; ── RESTRICCIONES BLANDAS ────────────────────────────────────────
    (when restricciones-blandas
      (format stream "    print('RESTRICCIONES BLANDAS  (tdpq / sbqp / minimizar):')~%")
      (loop for nombre in restricciones-blandas
            for i from (1+ (length restricciones-duras))
            do (let* ((nodo     (symbol-value nombre))
                      (tipo-str (comentario-restriccion (tipo-restriccion nodo)))
                      (math-str (restriccion->math-str nodo))
                      (q-refs   (consultas-en-restriccion nodo)))
                 (format stream "    print('  R~a  [~a]:')~%" i tipo-str)
                 (when math-str
                   (format stream "    print('    ~a')~%" math-str))
                 (when q-refs
                   (format stream "    print('    donde:')~%")
                   (dolist (q q-refs)
                     (let* ((q-nombre (nombre-consulta-py q))
                            (q-nodo   (gethash q-nombre *consultas-por-nombre*)))
                       (when q-nodo
                         (format stream "    print('      ~a')~%"
                                 (consulta->math-str q-nombre q-nodo))))))
                 (format stream "    print()~%")))
      (format stream "    print()~%"))

    (format stream "    print(sep)~%")
    (format stream "~%~%")))


;; =====================================================================
;; GENERADOR: mostrar_resultado  —  horario propuesto + evaluación
;;
;; ent-py  — nombre Python de la entidad combinación, ej. "asignacion"
;; id-py   — nombre Python del slot identidad, ej. "tribunal"
;; vars-py — lista de nombres Python de slots variables
;; =====================================================================

(defun generar-mostrar-resultado (restricciones-duras restricciones-blandas
                                  peso-dura peso-blanda
                                  ent-py id-py vars-py stream)
  (format stream "def mostrar_resultado(horario):~%")
  (format stream "    \"\"\"Imprime el horario decidido y cuantas restricciones se incumplen.\"\"\"~%")
  (format stream "    sep = '=' * 60~%")

  ;; ── HORARIO PROPUESTO ─────────────────────────────────────────────
  (format stream "    print(sep)~%")
  (format stream "    print('HORARIO PROPUESTO POR LA METAHEURISTICA')~%")
  (format stream "    print(sep)~%")
  (format stream "    print()~%")
  (format stream "    for i, asig in enumerate(horario.~a, 1):~%" ent-py)
  (format stream "        print(f'  Defensa {i}:')~%")
  (format stream "        print(f'    ~a : {asig.~a}')~%" (string-upcase id-py) id-py)
  (dolist (v vars-py)
    (format stream "        print(f'    ~a : {asig.~a}')~%"
            (string-upcase v) v))
  (format stream "        print()~%")

  ;; ── EVALUACIÓN DE RESTRICCIONES ───────────────────────────────────
  (format stream "    print(sep)~%")
  (format stream "    print('EVALUACION DE RESTRICCIONES')~%")
  (format stream "    print(sep)~%")
  (format stream "    costo_total = 0~%")

  (when restricciones-duras
    (format stream "    print('Restricciones simples / duras  (peso ~a):')~%" peso-dura)
    (dolist (nombre restricciones-duras)
      (let ((fn (py-nombre nombre)))
        (format stream "    v = ~a(horario)~%" fn)
        (format stream "    costo_total += PESO_DURA * v~%")
        (format stream "    print(f'  ~a: {v} incumplimientos  ->  costo: {PESO_DURA * v}')~%"
                fn))))

  (when restricciones-blandas
    (format stream "    print('Restricciones debiles / blandas  (peso ~a):')~%" peso-blanda)
    (dolist (nombre restricciones-blandas)
      (let ((fn (py-nombre nombre)))
        (format stream "    v = ~a(horario)~%" fn)
        (format stream "    costo_total += PESO_BLANDA * v~%")
        (format stream "    print(f'  ~a: {v}  ->  costo: {PESO_BLANDA * v}')~%" fn))))

  (format stream "    print(f'Costo total: {costo_total}')~%")
  (format stream "    print(sep)~%")
  (format stream "~%~%"))
