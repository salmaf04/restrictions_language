;; Clase principal que agrupa todo el AST
(defclass problema-horario ()
  ((nombre :initarg :nombre :accessor nombre)
   (entidades :initarg :entidades :initform '() :accessor entidades)
   (asignacion :initarg :asignacion :accessor asignacion)
   (restricciones :initarg :restricciones :initform '() :accessor restricciones)))

;; Clase para representar los nodos del bloque "Entidades"
(defclass definicion-entidad ()
  ((nombre :initarg :nombre :accessor nombre)
   (atributos :initarg :atributos :initform '() :accessor atributos))) ; Lista de strings o símbolos

;; Clase para el bloque "Asignación (Meta)"
(defclass definicion-asignacion ()
  ((origen :initarg :origen :accessor origen)     ; Ej: (Asignatura Grupo)
   (destino :initarg :destino :accessor destino)))   ; Ej: (Turno Aula)


(defclass definicion-restriccion ()
  ((nombre :initarg :nombre :accessor nombre)
   (tipo :initarg :tipo :initform "Fuerte" :accessor tipo)
   (sujeto :initarg :sujeto :accessor sujeto)
   (contexto :initarg :contexto :accessor contexto)
   (metrica :initarg :metrica :accessor metrica)
   (regla :initarg :regla :accessor regla))) ; Aquí va una instancia de 'condicion'

;; Clase base para cualquier condición
(defclass condicion () ())

;; Condición Simple: Comparación directa (Ej: <= 1)
(defclass condicion-simple (condicion)
  ((operador :initarg :operador :accessor operador) ; <=, ==, IN, !=
   (valor-referencia :initarg :valor-referencia :accessor valor-referencia)))

;; Condición Compuesta: Agrupa otras condiciones (Ej: OR, AND)
(defclass condicion-logica (condicion)
  ((operador-logico :initarg :operador-logico :accessor operador-logico) ; OR, AND, NOT
   (sub-condiciones :initarg :sub-condiciones :initform '() :accessor sub-condiciones)))