;; --- PROGRAMA ---
(def-entidad programa nombre tipo publico)

(defclass ref-gen-a-programa (ref-gen-entidad) ())
(defvar programa (make-instance 'ref-gen-a-programa :nombre-entidad 'programa))

(defclass ref-especifica-a-programa (ref-especifica-ent) 
  ((nombre  :initarg :nombre  :accessor programa-nombre)
   (tipo    :initarg :tipo    :accessor programa-tipo)
   (publico :initarg :publico :accessor programa-publico)))

;; --- DURACIÓN ---
(def-entidad duracion minutos)

(defclass ref-gen-a-duracion (ref-gen-entidad) ())
(defvar duracion (make-instance 'ref-gen-a-duracion :nombre-entidad 'duracion))

(defclass ref-especifica-a-duracion (ref-especifica-ent) 
  ((minutos :initarg :minutos :accessor duracion-minutos)))

;; --- DÍA ---
(def-entidad dia nombre fecha)

(defclass ref-gen-a-dia (ref-gen-entidad) ())
(defvar dia (make-instance 'ref-gen-a-dia :nombre-entidad 'dia))

(defclass ref-especifica-a-dia (ref-especifica-ent) 
  ((nombre :initarg :nombre :accessor dia-nombre)
   (fecha  :initarg :fecha  :accessor dia-fecha)))

;; --- DURACIÓN DE PROGRAMA ---
(def-entidad duracion-programa dia programa duracion)

(defclass ref-gen-a-duracion-programa (ref-gen-entidad) ())
(defvar duracion-programa (make-instance 'ref-gen-a-duracion-programa :nombre-entidad 'duracion-programa))

(defclass ref-especifica-a-duracion-programa (ref-especifica-ent) 
  ((dia      :initarg :dia      :accessor dp-dia)
   (programa :initarg :programa :accessor dp-programa)
   (duracion :initarg :duracion :accessor dp-duracion)))

;; --- HORA ---
(def-entidad hora hora minutos)

(defclass ref-gen-a-hora (ref-gen-entidad) ())
(defvar hora (make-instance 'ref-gen-a-hora :nombre-entidad 'hora))

(defclass ref-especifica-a-hora (ref-especifica-ent) 
  ((hora    :initarg :hora    :accessor hora-hora)
   (minutos :initarg :minutos :accessor hora-minutos)))

;; --- HORA INICIAL ---
(def-entidad hora-inicial hora)

(defclass ref-gen-a-hora-inicial (ref-gen-entidad) ())
(defvar hora-inicial (make-instance 'ref-gen-a-hora-inicial :nombre-entidad 'hora-inicial))

(defclass ref-especifica-a-hora-inicial (ref-especifica-ent) 
  ((hora :initarg :hora :accessor hi-hora)))

;; --- RANGO DE HORA ---
(def-entidad rango-hora hora-inicio hora-fin)

(defclass ref-gen-a-rango-hora (ref-gen-entidad) ())
(defvar rango-hora (make-instance 'ref-gen-a-rango-hora :nombre-entidad 'rango-hora))

(defclass ref-especifica-a-rango-hora (ref-especifica-ent) 
  ((hora-inicio :initarg :hora-inicio :accessor rango-inicio)
   (hora-fin    :initarg :hora-fin    :accessor rango-fin)))

;; --- PLANIFICACIÓN ---
(def-entidad planificacion (hora inicio, dia, programacion, duracion-programa))

(defclass ref-gen-a-planificacion (ref-gen-entidad) ())
(defvar planificacion (make-instance 'ref-gen-a-planificacion :nombre-entidad 'planificacion))

(defclass ref-especifica-a-planificacion (ref-especifica-ent) 
  ((hora-inicio :initarg :hora-inicio :accessor planificacion-hora-inicio
    dia :initarg :dia :accessor planificacion-dia
    progrmacion :initarg :progrmacion :accessor planificacion-progrmacion
    duracion-programa :initarg :duracion-programa :accessor planificacion-duracion-programa)))

;; Restricción: No pueden haber dos programas del mismo tipo seguidos

(defvar consulta-adyacentes-mismo-tipo
  (make-instance 'consulta-simple
    :args '(planificacion-actual)
    :variable-iteracion '(asig-1 asig-2)
    :dominio-iteracion planificacion 
    
    :comprobacion 
    (make-instance 'op-and
      ;; Mismo día y mismo tipo
      :izq (make-instance 'op-and
             :izq (make-instance 'op-igual
                    :izq (make-instance 'acceso-a-atributo-de-entidad :atributo 'dia :entidad 'asig-1)
                    :der (make-instance 'acceso-a-atributo-de-entidad :atributo 'dia :entidad 'asig-2))
             :der (make-instance 'op-igual
                    :izq (make-instance 'acceso-a-atributo-de-entidad :atributo 'tipo 
                           :entidad (make-instance 'acceso-a-atributo-de-entidad :atributo 'programa :entidad 'asig-1))
                    :der (make-instance 'acceso-a-atributo-de-entidad :atributo 'tipo 
                           :entidad (make-instance 'acceso-a-atributo-de-entidad :atributo 'programa :entidad 'asig-2))))
      
      ;; Adyacencia (Fin de 1 == Inicio de 2  Ó  Fin de 2 == Inicio de 1)
      :der (make-instance 'op-or
             :izq (make-instance 'op-igual
                    :izq (make-instance 'op-suma 
                           :izq (make-instance 'acceso-a-atributo-de-entidad :atributo 'hora-inicio :entidad 'asig-1)
                           :der (make-instance 'acceso-a-atributo-de-entidad :atributo 'duracion :entidad 'asig-1))
                    :der (make-instance 'acceso-a-atributo-de-entidad :atributo 'hora-inicio :entidad 'asig-2))
             :der (make-instance 'op-igual
                    :izq (make-instance 'op-suma 
                           :izq (make-instance 'acceso-a-atributo-de-entidad :atributo 'hora-inicio :entidad 'asig-2)
                           :der (make-instance 'acceso-a-atributo-de-entidad :atributo 'duracion :entidad 'asig-2))
                    :der (make-instance 'acceso-a-atributo-de-entidad :atributo 'hora-inicio :entidad 'asig-1))))
    
    :operacion 'contar
    :retorno 'cantidad-adyacentes))

