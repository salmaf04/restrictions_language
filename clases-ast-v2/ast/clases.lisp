;; --- CLASES BASE ---
(defclass ref-gen-entidad ()
  ((nombre-entidad :initarg :nombre-entidad :reader nombre-entidad)))

(defclass ref-especifica-ent () ())

;; --- MACRO DE DEFINICIÓN ---
(defmacro def-entidad (nombre &rest atributos)
  `(progn
     (setf (get ',nombre 'atributos-entidad) ',atributos)
     ',nombre))

(defclass nodo-ast () ()
  (:documentation "Clase base absoluta para todos los nodos del árbol."))

;; --- Estructura de datos y agrupaciones ---
;; Recibe una lista de entidades específicas
(defclass comb-entidades (nodo-ast)
  ((entidades :initarg :entidades :accessor comb-entidades-lista)))

;; Recibe una lista de cualquier cosa
(defclass lista (nodo-ast)
  ((elementos :initarg :elementos :accessor lista-elementos)))

;; --- Acceso a datos ---
;; Recibe un atributo (símbolo) y una entidad (instancia)
(defclass acceso-a-atributo-de-entidad (nodo-ast)
  ((atributo :initarg :atributo :accessor acceso-atributo)
   (entidad  :initarg :entidad  :accessor acceso-entidad)))

;; Recibe una entidad y una combinación de entidades
(defclass acceso-a-elemento-de-comb (nodo-ast)
  ((entidad        :initarg :entidad        :accessor acceso-comb-entidad)
   (comb-entidades :initarg :comb-entidades :accessor acceso-comb-origen)))

;; --- Consulta ---
(defclass consulta-simple (nodo-ast)
  ((args               :initarg :args               :accessor consulta-args)
   (variable-iteracion :initarg :variable-iteracion :accessor consulta-var-iter)
   (dominio-iteracion  :initarg :dominio-iteracion  :accessor consulta-dominio)
   (comprobacion       :initarg :comprobacion       :accessor consulta-comprobacion)
   (operacion          :initarg :operacion          :accessor consulta-operacion)
   (retorno            :initarg :retorno            :accessor consulta-retorno)))

;; --- CUANTIFICADORES ---

;; Clase padre abstracta para los cuantificadores
(defclass cuantificador-restriccion (nodo-ast)
  ((operador     :initarg :operador     :accessor cuanti-operador)
   (comprobacion :initarg :comprobacion :accessor cuanti-comprobacion)
   (elemento     :initarg :elemento     :accessor cuanti-elemento)))

;; Clases específicas que heredan la estructura
(defclass nppq (cuantificador-restriccion) ())
(defclass tqpq (cuantificador-restriccion) ())
(defclass tdpq (cuantificador-restriccion) ())
(defclass sbqp (cuantificador-restriccion) ())

;; --- Comprobaciones de conjuntos ---
(defclass hay-elementos-duplicados (nodo-ast)
  ((lista :initarg :lista :accessor check-duplicados-lista)))

(defclass pertenece (nodo-ast)
  ((elemento  :initarg :elemento  :accessor pertenece-elemento)
   (coleccion :initarg :coleccion :accessor pertenece-coleccion)))


;; --- Operaciones aritmeticas y logicas ---
(defclass operacion-binaria (nodo-ast)
  ((operando-izq :initarg :izq :accessor op-izq)
   (operando-der :initarg :der :accessor op-der)))

(defclass operacion-unaria (nodo-ast)
  ((operando :initarg :operando :accessor op-operando)))

;; --- Categorías Semánticas ---
(defclass operacion-aritmetica     (operacion-binaria) ())
(defclass comprobacion-aritmetica  (operacion-binaria) ())
(defclass operacion-logica-binaria (operacion-binaria) ())
(defclass operacion-logica-unaria  (operacion-unaria)  ())

;; --- Nodos de Operaciones Lógicas ---
(defclass op-and (operacion-logica-binaria) ())
(defclass op-or  (operacion-logica-binaria) ())
(defclass op-not (operacion-logica-unaria)  ())

;; --- Nodos de Comprobaciones Relacionales ---
(defclass op-igual       (comprobacion-aritmetica) ())
(defclass op-distinto    (comprobacion-aritmetica) ())
(defclass op-mayor       (comprobacion-aritmetica) ())
(defclass op-menor       (comprobacion-aritmetica) ())
(defclass op-mayor-igual (comprobacion-aritmetica) ())
(defclass op-menor-igual (comprobacion-aritmetica) ())

;; --- Nodos de Operaciones Aritméticas ---
(defclass op-suma           (operacion-aritmetica) ())
(defclass op-resta          (operacion-aritmetica) ())
(defclass op-multiplicacion (operacion-aritmetica) ())
(defclass op-division       (operacion-aritmetica) ())