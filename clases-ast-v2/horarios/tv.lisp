;; =====================================================================
;; MODELADO DEL DOMINIO: HORARIO DE TELEVISIÓN
;; =====================================================================

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
(def-entidad planificacion hora-inicio dia programacion duracion-programa)

(defclass ref-gen-a-planificacion (ref-gen-entidad) ())
(defvar planificacion (make-instance 'ref-gen-a-planificacion :nombre-entidad 'planificacion))

(defclass ref-especifica-a-planificacion (ref-especifica-ent) 
  ((hora-inicio       :initarg :hora-inicio       :accessor planificacion-hora-inicio)
   (dia               :initarg :dia               :accessor planificacion-dia)
   (programacion      :initarg :programacion      :accessor planificacion-programacion)
   (duracion-programa :initarg :duracion-programa :accessor planificacion-duracion-programa)))


;; =====================================================================
;; RESTRICCIONES Y CONSULTAS (CONSTRUIDAS CON EL AST OPTIMIZADO)
;; =====================================================================

;; Restricción: No pueden haber dos programas del mismo tipo seguidos (adyacentes)
(defvar consulta-adyacentes-mismo-tipo
  (def-consulta-simple
    :args '(planificacion-actual)
    :variable-iteracion '(asig-1 asig-2)
    :dominio-iteracion planificacion 
    
    :comprobacion 
    (def-and 
      ;; --- Bloque Izquierdo: Mismo día AND Mismo tipo ---
      (def-and 
        ;; Mismo día
        (def-igual (def-acceso-atributo 'asig-1 'dia) 
                   (def-acceso-atributo 'asig-2 'dia))
        ;; Mismo tipo de programa (Acceso anidado: asig -> programa -> tipo)
        (def-igual (def-acceso-atributo (def-acceso-atributo 'asig-1 'programa) 'tipo)
                   (def-acceso-atributo (def-acceso-atributo 'asig-2 'programa) 'tipo)))
      
      ;; --- Bloque Derecho: Adyacencia Temporal (Fin1 == Inicio2 Ó Fin2 == Inicio1) ---
      (def-or 
        ;; ¿Termina asig-1 cuando arranca asig-2?
        (def-igual (def-suma (def-acceso-atributo 'asig-1 'hora-inicio) 
                             (def-acceso-atributo 'asig-1 'duracion))
                   (def-acceso-atributo 'asig-2 'hora-inicio))
        ;; ¿Termina asig-2 cuando arranca asig-1?
        (def-igual (def-suma (def-acceso-atributo 'asig-2 'hora-inicio) 
                             (def-acceso-atributo 'asig-2 'duracion))
                   (def-acceso-atributo 'asig-1 'hora-inicio))))
    
    :operacion 'contar
    :retorno 'cantidad-adyacentes))

;; =====================================================================
;; DEFINICIÓN DE LA RESTRICCIÓN
;; =====================================================================

;; NPPQ: No Puede Pasar Que (La cantidad de adyacentes del mismo tipo sea > 0)
(defvar restriccion-sin-adyacentes-mismo-tipo
  (def-nppq 
    ;; Comprobación lógica: ¿El resultado de la consulta es mayor a 0?
    (def-mayor consulta-adyacentes-mismo-tipo 0)))

