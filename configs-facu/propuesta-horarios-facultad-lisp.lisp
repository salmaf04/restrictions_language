(defclass aula ()
  ((nombre :initarg :nombre :reader aula-nombre)
   (capacidad :initarg :capacidad :reader aula-capacidad)))

;; Representación de las aulas y sus capacidades
(defparameter *aulas-disponibles*
  (list (make-instance 'aula :nombre "Aula 1" :capacidad 30)
        (make-instance 'aula :nombre "Aula 6" :capacidad 70)
        (make-instance 'aula :nombre "SEDER" :capacidad nil)))

;; Representación de la carga docente de primer año (D1)
(defparameter *asignaturas-d1*
  '((:nombre "Álgebra Lineal C" :frecuencia 2)
    (:nombre "Introducción a la Programación C" :frecuencia 1)
    (:nombre "Lógica C" :frecuencia 1)))

;;Horario de Grupo 

(defstruct turno-clase
  dia
  turno
  asignatura
  aula)

(defstruct horario-grupo
  grupo
  carrera
  clases)

;; Modelando el horario del grupo D111
(defparameter *horario-d111*
  (make-horario-grupo
   :grupo "111"
   :carrera D 
   :clases (list 
            (make-turno-clase :dia 'lunes :turno 1 :asignatura "Álgebra Lineal C" :aula "7")
            (make-turno-clase :dia 'lunes :turno 2 :asignatura "Introducción a la Programación C" :aula "7")
            (make-turno-clase :dia 'miércoles :turno 2 :asignatura "Educación Física I" :aula "SEDER"))))