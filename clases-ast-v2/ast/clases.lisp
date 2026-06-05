;; =====================================================================
;; BASE
;; =====================================================================

(defclass nodo-ast () ()
  (:documentation "Clase base absoluta para todos los nodos del árbol."))


;; =====================================================================
;; ENTIDADES
;; =====================================================================

(defclass ref-gen-entidad ()
  ((nombre-entidad :initarg :nombre-entidad :reader nombre-entidad)))

(defclass ref-especifica-ent () ())

(defmacro def-entidad (nombre &rest atributos)
  `(progn
     (setf (get ',nombre 'atributos-entidad) ',atributos)
     ',nombre))


;; =====================================================================
;; ESTRUCTURAS DE DATOS
;; =====================================================================

;; Recibe una lista de entidades específicas
(defclass comb-entidades (nodo-ast)
  ((entidades :initarg :entidades :accessor comb-entidades-lista)))

(defun def-comb-entidades (entidades)
  (make-instance 'comb-entidades :entidades entidades))

;; Recibe una lista de cualquier cosa
(defclass lista (nodo-ast)
  ((elementos :initarg :elementos :accessor lista-elementos)))

(defun def-lista (elementos)
  (make-instance 'lista :elementos elementos))


;; =====================================================================
;; ACCESO A DATOS
;; =====================================================================

;; Recibe un atributo (símbolo) y una entidad (instancia)
(defclass acceso-a-atributo-de-entidad (nodo-ast)
  ((atributo :initarg :atributo :accessor acceso-atributo)
   (entidad  :initarg :entidad  :accessor acceso-entidad)))

(defun def-acceso-atributo (entidad atributo)
  (make-instance 'acceso-a-atributo-de-entidad :entidad entidad :atributo atributo))

;; Recibe una entidad y una combinación de entidades
(defclass acceso-a-elemento-de-comb (nodo-ast)
  ((entidad        :initarg :entidad        :accessor acceso-comb-entidad)
   (comb-entidades :initarg :comb-entidades :accessor acceso-comb-origen)))

(defun def-acceso-comb (entidad comb-entidades)
  (make-instance 'acceso-a-elemento-de-comb :entidad entidad :comb-entidades comb-entidades))


;; =====================================================================
;; CONSULTA
;; =====================================================================

(defclass consulta-simple (nodo-ast)
  ((args               :initarg :args               :accessor consulta-args)
   (variable-iteracion :initarg :variable-iteracion :accessor consulta-var-iter)
   (dominio-iteracion  :initarg :dominio-iteracion  :accessor consulta-dominio)
   (comprobacion       :initarg :comprobacion       :accessor consulta-comprobacion)
   (operacion          :initarg :operacion          :accessor consulta-operacion)
   (retorno            :initarg :retorno            :accessor consulta-retorno)))

(defun def-consulta-simple (&key args variable-iteracion dominio-iteracion comprobacion operacion retorno)
  (make-instance 'consulta-simple
                 :args args
                 :variable-iteracion variable-iteracion
                 :dominio-iteracion dominio-iteracion
                 :comprobacion comprobacion
                 :operacion operacion
                 :retorno retorno))


;; =====================================================================
;; CUANTIFICADORES
;; =====================================================================

(defclass cuantificador-restriccion (nodo-ast)
  ((operador     :initarg :operador     :accessor cuanti-operador)
   (comprobacion :initarg :comprobacion :accessor cuanti-comprobacion)
   (elemento     :initarg :elemento     :accessor cuanti-elemento)))

(defclass nppq (cuantificador-restriccion) ())
(defclass tqpq (cuantificador-restriccion) ())
(defclass tdpq (cuantificador-restriccion) ())
(defclass sbqp (cuantificador-restriccion) ())

(defun def-nppq (comprobacion &optional elemento)
  (make-instance 'nppq :comprobacion comprobacion :elemento elemento))

(defun def-tqpq (comprobacion &optional elemento)
  (make-instance 'tqpq :comprobacion comprobacion :elemento elemento))

(defun def-tdpq (comprobacion &optional elemento)
  (make-instance 'tdpq :comprobacion comprobacion :elemento elemento))

(defun def-sbqp (comprobacion &optional elemento)
  (make-instance 'sbqp :comprobacion comprobacion :elemento elemento))


;; =====================================================================
;; COMPROBACIONES DE CONJUNTOS
;; =====================================================================

(defclass hay-elementos-duplicados (nodo-ast)
  ((lista :initarg :lista :accessor check-duplicados-lista)))

(defun def-hay-duplicados (lista)
  (make-instance 'hay-elementos-duplicados :lista lista))

(defclass pertenece (nodo-ast)
  ((elemento  :initarg :elemento  :accessor pertenece-elemento)
   (coleccion :initarg :coleccion :accessor pertenece-coleccion)))

(defun def-pertenece (elemento coleccion)
  (make-instance 'pertenece :elemento elemento :coleccion coleccion))


;; =====================================================================
;; OPERACIONES
;; =====================================================================

;; --- Clases base ---
(defclass operacion-binaria (nodo-ast)
  ((operando-izq :initarg :izq :accessor op-izq)
   (operando-der :initarg :der :accessor op-der)))

(defclass operacion-unaria (nodo-ast)
  ((operando :initarg :operando :accessor op-operando)))

;; --- Categorías semánticas ---
(defclass operacion-aritmetica     (operacion-binaria) ())
(defclass comprobacion-aritmetica  (operacion-binaria) ())
(defclass operacion-logica-binaria (operacion-binaria) ())
(defclass operacion-logica-unaria  (operacion-unaria)  ())

;; --- Lógicas ---
(defclass op-and (operacion-logica-binaria) ())
(defclass op-or  (operacion-logica-binaria) ())
(defclass op-not (operacion-logica-unaria)  ())

(defun def-and (izq der) (make-instance 'op-and :izq izq :der der))
(defun def-or  (izq der) (make-instance 'op-or  :izq izq :der der))
(defun def-not (op)      (make-instance 'op-not :operando op))

;; --- Relacionales ---
(defclass op-igual       (comprobacion-aritmetica) ())
(defclass op-distinto    (comprobacion-aritmetica) ())
(defclass op-mayor       (comprobacion-aritmetica) ())
(defclass op-menor       (comprobacion-aritmetica) ())
(defclass op-mayor-igual (comprobacion-aritmetica) ())
(defclass op-menor-igual (comprobacion-aritmetica) ())

(defun def-igual       (izq der) (make-instance 'op-igual       :izq izq :der der))
(defun def-distinto    (izq der) (make-instance 'op-distinto    :izq izq :der der))
(defun def-mayor       (izq der) (make-instance 'op-mayor       :izq izq :der der))
(defun def-menor       (izq der) (make-instance 'op-menor       :izq izq :der der))
(defun def-mayor-igual (izq der) (make-instance 'op-mayor-igual :izq izq :der der))
(defun def-menor-igual (izq der) (make-instance 'op-menor-igual :izq izq :der der))

;; --- Aritméticas ---
(defclass op-suma           (operacion-aritmetica) ())
(defclass op-resta          (operacion-aritmetica) ())
(defclass op-multiplicacion (operacion-aritmetica) ())
(defclass op-division       (operacion-aritmetica) ())

(defun def-suma           (izq der) (make-instance 'op-suma           :izq izq :der der))
(defun def-resta          (izq der) (make-instance 'op-resta          :izq izq :der der))
(defun def-multiplicacion (izq der) (make-instance 'op-multiplicacion :izq izq :der der))
(defun def-division       (izq der) (make-instance 'op-division       :izq izq :der der))
