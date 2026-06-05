;; =====================================================================
;; MODELADO DEL DOMINIO: HORARIO DE TESIS
;; =====================================================================

;; --- GRADO ---
;; Valores posibles: lic., Msc., Dr.
(defclass ref-especifica-a-grado (ref-especifica-ent)
  ((nombre :initarg :nombre :accessor grado-nombre)))

(defun def-grado (nombre) (make-instance 'ref-especifica-a-grado :nombre nombre))

(defvar grado-lic (def-grado 'lic.))
(defvar grado-msc (def-grado 'Msc.))
(defvar grado-dr  (def-grado 'Dr.))

;; --- PROFESOR ---
(def-entidad profesor id nombre grado)

(defclass ref-gen-a-profesor (ref-gen-entidad) ())
(defvar profesor (make-instance 'ref-gen-a-profesor :nombre-entidad 'profesor))

(defclass ref-especifica-a-profesor (ref-especifica-ent)
  ((id     :initarg :id     :accessor profesor-id)
   (nombre :initarg :nombre :accessor profesor-nombre)
   (grado  :initarg :grado  :accessor profesor-grado)))

;; --- ESTUDIANTE ---
(def-entidad estudiante id nombre)

(defclass ref-gen-a-estudiante (ref-gen-entidad) ())
(defvar estudiante (make-instance 'ref-gen-a-estudiante :nombre-entidad 'estudiante))

(defclass ref-especifica-a-estudiante (ref-especifica-ent)
  ((id     :initarg :id     :accessor estudiante-id)
   (nombre :initarg :nombre :accessor estudiante-nombre)))

;; --- TESIS ---
(def-entidad tesis id estudiante tutor oponente presidente secretario vocal)

(defclass ref-gen-a-tesis (ref-gen-entidad) ())
(defvar tesis (make-instance 'ref-gen-a-tesis :nombre-entidad 'tesis))

(defclass ref-especifica-a-tesis (ref-especifica-ent)
  ((id         :initarg :id         :accessor tesis-id)
   (estudiante :initarg :estudiante :accessor tesis-estudiante)
   (tutor      :initarg :tutor      :accessor tesis-tutor)
   (oponente   :initarg :oponente   :accessor tesis-oponente)
   (presidente :initarg :presidente :accessor tesis-presidente)
   (secretario :initarg :secretario :accessor tesis-secretario)
   (vocal      :initarg :vocal      :accessor tesis-vocal)))

;; --- DÍA ---
;; Valores posibles: 1/6, 2/6, 3/6
(defclass ref-especifica-a-dia (ref-especifica-ent)
  ((nombre :initarg :nombre :accessor dia-nombre)))

(defun def-dia (nombre) (make-instance 'ref-especifica-a-dia :nombre nombre))

(defvar dia-1/6 (def-dia '1/6))
(defvar dia-2/6 (def-dia '2/6))
(defvar dia-3/6 (def-dia '3/6))

;; --- HORA ---
;; Valores posibles: 9am, 11am, 1pm, 3pm
(defclass ref-especifica-a-hora (ref-especifica-ent)
  ((nombre :initarg :nombre :accessor hora-nombre)))

(defun def-hora (nombre) (make-instance 'ref-especifica-a-hora :nombre nombre))

(defvar hora-9am  (def-hora '9am))
(defvar hora-11am (def-hora '11am))
(defvar hora-1pm  (def-hora '1pm))
(defvar hora-3pm  (def-hora '3pm))

;; --- LOCAL ---
(def-entidad local nombre)

(defclass ref-gen-a-local (ref-gen-entidad) ())
(defvar local (make-instance 'ref-gen-a-local :nombre-entidad 'local))

(defclass ref-especifica-a-local (ref-especifica-ent)
  ((nombre :initarg :nombre :accessor local-nombre)))

;; --- PLANIFICACIÓN ---
;; Asocia una tesis con un local, un día y una hora
(def-entidad planificacion tesis local dia hora)

(defclass ref-gen-a-planificacion (ref-gen-entidad) ())
(defvar planificacion (make-instance 'ref-gen-a-planificacion :nombre-entidad 'planificacion))

(defclass ref-especifica-a-planificacion (ref-especifica-ent)
  ((tesis  :initarg :tesis  :accessor planificacion-tesis)
   (local  :initarg :local  :accessor planificacion-local)
   (dia    :initarg :dia    :accessor planificacion-dia)
   (hora   :initarg :hora   :accessor planificacion-hora)))

;; =====================================================================
;; RESTRICCIONES Y CONSULTAS (CONSTRUIDAS CON EL AST)
;; =====================================================================

;; Para una planificación dada, reúne todos los profesores del tribunal
;; de TODAS las planificaciones en la misma franja (día + hora).
(defvar query-tribunal-en-franja
  (def-consulta-simple
    :args '(plan-actual)
    :variable-iteracion '(plan)
    :dominio-iteracion planificacion
    :comprobacion
    (def-and
      (def-igual (def-acceso-atributo 'plan 'dia)
                 (def-acceso-atributo 'plan-actual 'dia))
      (def-igual (def-acceso-atributo 'plan 'hora)
                 (def-acceso-atributo 'plan-actual 'hora)))
    :operacion 'acumular-tribunal
    :retorno 'tribunal-en-franja))

;; =====================================================================
;; DEFINICIÓN DE LAS RESTRICCIONES
;; =====================================================================

;; NPPQ: no puede pasar que la cantidad de profesores en conflicto sea mayor que 0
(defvar restriccion-sin-conflicto-profesor
  (def-nppq
    (def-mayor query-tribunal-en-franja 0)))
