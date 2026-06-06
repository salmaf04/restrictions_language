;; =====================================================================
;; DOMINIO: HORARIO DE TESIS
;; =====================================================================


;; =====================================================================
;; MIXINS
;; =====================================================================

(defclass* tiene-nombre ()
  (nombre))


;; =====================================================================
;; ENTIDADES ENUMERADAS
;; =====================================================================

(def-entidad grado () (id))

(def-grado grado-lic "Lic")
(def-grado grado-msc "Msc")
(def-grado grado-dr  "Dr")


;; =====================================================================
;; ENTIDADES PRINCIPALES
;; =====================================================================

(def-entidad profesor (tiene-nombre)
  (grado))

(def-entidad estudiante (tiene-nombre))

(def-entidad tribunal ()
  (estudiante tutor oponente presidente vocal secretario))

(def-entidad fecha ()
  (dia mes))

(def-entidad momento ()
  (hora))

(def-entidad local (tiene-nombre))


;; =====================================================================
;; COMBINACIÓN: ASIGNACIÓN
;; =====================================================================

(def-comb asignacion
  (tribunal fecha momento local))


;; =====================================================================
;; CONSULTAS
;; =====================================================================

(def-consulta profesor-en-tribunal (prof asig)
  :comprueba
  (def-op-or (def-op-igual (tutor      (tribunal asig)) prof)
             (def-op-igual (oponente   (tribunal asig)) prof)
             (def-op-igual (presidente (tribunal asig)) prof)
             (def-op-igual (vocal      (tribunal asig)) prof)
             (def-op-igual (secretario (tribunal asig)) prof)))

(def-consulta conflictos-de-horario ()
  :itera-sobre (p profesor) (a1 asignacion) (a2 asignacion)
  :comprueba
  (def-op-and (profesor-en-tribunal p a1)
              (profesor-en-tribunal p a2)
              (def-op-igual    (fecha    a1) (fecha    a2))
              (def-op-igual    (momento  a1) (momento  a2))
              (def-op-distinto (tribunal a1) (tribunal a2)))
  :operacion suma
  :devuelve 1)


;; =====================================================================
;; RESTRICCIONES
;; =====================================================================

;; Restricción fuerte: ningún profesor en dos defensas a la vez
(defvar restriccion-sin-conflictos-de-horario
  (def-nppq (def-op-mayor conflictos-de-horario 0)))


;; Cuenta cuántos días distintos tiene que asistir un profesor dado
(def-consulta dias-asistidos (prof)
  :itera-sobre (asig asignacion)
  :comprueba (profesor-en-tribunal prof asig)
  :operacion contar-distintos-dias
  :devuelve n-dias)

;; Restricción blanda: minimizar la carga del profesor que más días asiste
;; (el que más días tiene que ir, que vaya los menos posibles)
(defvar restriccion-minimizar-carga-maxima
  (def-minimizar dias-asistidos profesor))


;; =====================================================================
;; DATOS CONCRETOS DEL DOMINIO
;; =====================================================================

;; Profesores
(def-profesor prof-piad     "Alejandro Piad"    grado-dr)
(def-profesor prof-suarez   "Carlos Suarez"     grado-msc)
(def-profesor prof-garcia   "Maria Garcia"      grado-dr)
(def-profesor prof-torres   "Luis Torres"       grado-msc)
(def-profesor prof-mendez   "Ana Mendez"        grado-dr)
(def-profesor prof-herrera  "Pedro Herrera"     grado-msc)

;; Estudiantes
(def-estudiante est-rodriguez "Laura Rodriguez")
(def-estudiante est-fernandez "Carlos Fernandez")
(def-estudiante est-lopez     "Sofia Lopez")

;; Tribunales (uno por defensa)
(def-tribunal trib-1 est-rodriguez prof-piad   prof-suarez  prof-garcia  prof-torres  prof-mendez)
(def-tribunal trib-2 est-fernandez prof-garcia prof-herrera prof-piad    prof-suarez  prof-torres)
(def-tribunal trib-3 est-lopez     prof-mendez prof-torres  prof-suarez  prof-herrera prof-garcia)

;; Fechas disponibles
(def-fecha fecha-1 1 6)
(def-fecha fecha-2 2 6)
(def-fecha fecha-3 3 6)

;; Momentos disponibles
(def-momento momento-manana 9)
(def-momento momento-mediodia 11)
(def-momento momento-tarde 14)

;; Locales disponibles
(def-local local-a "Sala A")
(def-local local-b "Sala B")
