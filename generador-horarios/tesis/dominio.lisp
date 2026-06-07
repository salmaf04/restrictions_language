;; =====================================================================
;; DOMINIO: HORARIO DE DEFENSAS DE TESIS
;; =====================================================================
;; Cómo ejecutar (PowerShell, desde la carpeta generador-horarios/):
;;
;;   cd "C:\Users\salma\OneDrive\Desktop\Tesis\generador-horarios"
;;   & "C:\Program Files\Steel Bank Common Lisp\sbcl.exe" --script tesis/dominio.lisp
;;
;; Luego para ver el resultado:
;;
;;   python tesis/horario.py
;;
;; Genera: tesis/horario.py
;; =====================================================================

;; ── Cargar infraestructura ─────────────────────────────────────────
(load (merge-pathnames "lib/clases-macros.lisp"
                       (truename ".")))
(load (merge-pathnames "lib/generador.lisp"
                       (truename ".")))


;; =====================================================================
;; MIXINS
;; =====================================================================

(defclass* tiene-nombre ()
  (nombre))


;; =====================================================================
;; ENTIDADES DEL DOMINIO
;; =====================================================================

;; Grado académico (enumeración)
(def-entidad grado () (id))

;; Personas
(def-entidad profesor   (tiene-nombre) (grado))
(def-entidad estudiante (tiene-nombre))

;; Tribunal: agrupa las personas que evalúan una defensa
(def-entidad tribunal ()
  (estudiante tutor oponente presidente vocal secretario))

;; Recursos de tiempo y espacio
(def-entidad fecha   () (dia mes))
(def-entidad momento () (hora))
(def-entidad local   (tiene-nombre))


;; =====================================================================
;; ENTIDAD COMBINACIÓN: ASIGNACIÓN
;; Una asignación = un tribunal + cuándo y dónde defiende
;; =====================================================================

(def-comb asignacion
  (tribunal fecha momento local))


;; =====================================================================
;; CONSULTAS Y RESTRICCIONES
;; =====================================================================

;; Auxiliar: ¿está el profesor prof en el tribunal de la asignación asig?
(def-consulta profesor-en-tribunal (prof asig)
  :comprueba
  (op-or (op-igual (tutor      (tribunal asig)) prof)
             (op-igual (oponente   (tribunal asig)) prof)
             (op-igual (presidente (tribunal asig)) prof)
             (op-igual (vocal      (tribunal asig)) prof)
             (op-igual (secretario (tribunal asig)) prof)))


;; Consulta: cuántas veces un profesor está en dos defensas simultáneas
(def-consulta conflictos-de-horario ()
  :itera-sobre (p profesor) (a1 asignacion) (a2 asignacion)
  :comprueba
  (op-and (profesor-en-tribunal p a1)
              (profesor-en-tribunal p a2)
              (op-igual    (fecha    a1) (fecha    a2))
              (op-igual    (momento  a1) (momento  a2))
              (op-distinto (tribunal a1) (tribunal a2)))
  :operacion suma
  :devuelve 1)

;; Restricción DURA (nppq): ningún profesor puede estar en dos defensas a la vez
(defvar restriccion-sin-conflictos-de-horario
  (def-nppq (op-mayor conflictos-de-horario 0)))


;; Consulta: cuántos días distintos asiste un profesor
(def-consulta dias-asistidos (prof)
  :itera-sobre (asig asignacion)
  :comprueba (profesor-en-tribunal prof asig)
  :operacion contar-distintos-dias
  :devuelve n-dias)

;; Restricción BLANDA (minimizar): minimizar la carga del profesor que más días asiste
(defvar restriccion-minimizar-carga-maxima
  (def-minimizar dias-asistidos profesor))


;; =====================================================================
;; DATOS CONCRETOS
;; Agrega aquí todas las instancias de tu problema real.
;; El generador las usa para construir el horario en la metaheurística.
;; =====================================================================

;; -- Grados --
(def-grado grado-lic "Lic")
(def-grado grado-msc "Msc")
(def-grado grado-dr  "Dr")

;; -- Profesores --
(def-profesor prof-piad    "Alejandro Piad"   grado-dr)
(def-profesor prof-suarez  "Carlos Suarez"    grado-msc)
(def-profesor prof-garcia  "Maria Garcia"     grado-dr)
(def-profesor prof-torres  "Luis Torres"      grado-msc)
(def-profesor prof-mendez  "Ana Mendez"       grado-dr)
(def-profesor prof-herrera "Pedro Herrera"    grado-msc)

;; -- Estudiantes --
(def-estudiante est-rodriguez "Laura Rodriguez")
(def-estudiante est-fernandez "Carlos Fernandez")
(def-estudiante est-lopez     "Sofia Lopez")

;; -- Tribunales (uno por defensa) --
;;   orden de argumentos: estudiante tutor oponente presidente vocal secretario
(def-tribunal trib-1 est-rodriguez prof-piad   prof-suarez  prof-garcia  prof-torres  prof-mendez)
(def-tribunal trib-2 est-fernandez prof-garcia prof-herrera prof-piad    prof-suarez  prof-torres)
(def-tribunal trib-3 est-lopez     prof-mendez prof-torres  prof-suarez  prof-herrera prof-garcia)

;; -- Fechas disponibles (dia mes) --
(def-fecha fecha-1 1 6)
(def-fecha fecha-2 2 6)
(def-fecha fecha-3 3 6)

;; -- Momentos disponibles (hora) --
(def-momento momento-manana   9)
(def-momento momento-mediodia 11)
(def-momento momento-tarde    14)

;; -- Locales disponibles --
(def-local local-a "Sala A")
(def-local local-b "Sala B")


;; =====================================================================
;; GENERAR CÓDIGO PYTHON
;; =====================================================================

(generar-python "tesis/horario.py"
  ;; Entidad combinación: lo que constituye una "fila" del horario
  :entidad-horario   'asignacion
  ;; Slot fijo (identidad): hay una asignación POR tribunal
  :slot-identidad    'tribunal
  ;; Slots variables: el GA elige estos de entre los pools de arriba
  :slots-variables   '(fecha momento local)
  ;; Consultas con nodo AST (defvar con :itera-sobre)
  :consultas         '(conflictos-de-horario dias-asistidos)
  ;; Restricciones simples / duras
  :restricciones-duras   '(restriccion-sin-conflictos-de-horario)
  ;; Restricciones débiles / blandas
  :restricciones-blandas '(restriccion-minimizar-carga-maxima)
  ;; Pesos del modelo matemático
  :peso-dura   1000
  :peso-blanda    1)

(sb-ext:exit)
