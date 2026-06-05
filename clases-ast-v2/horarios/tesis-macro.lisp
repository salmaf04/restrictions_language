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

(defvar restriccion-sin-conflictos-de-horario
  (def-nppq (def-op-mayor conflictos-de-horario 0)))
