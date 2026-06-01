;; Macro para constructores de AST
(defmacro crear-constructor (nombre-funcion nombre-clase lista-argumentos &rest slots-fijos)
  (let ((variables-limpias (remove-if (lambda (x) (member x '(&optional &rest &key)))
                                      (mapcar (lambda (x) (if (listp x) (car x) x)) lista-argumentos))))
    `(defun ,nombre-funcion ,lista-argumentos
       (make-instance ',nombre-clase
                      ,@slots-fijos
                      ,@(loop for var in variables-limpias
                              append (list (intern (symbol-name var) "KEYWORD") var))))))

;; Genera: (defun entidad (nombre atributos) (make-instance 'definicion-entidad :nombre nombre :atributos atributos))
(crear-constructor entidad definicion-entidad (nombre atributos))

;; Genera la función asignacion 
(crear-constructor asignacion definicion-asignacion (origen destino))

;; Genera la función para condiciones simples
(crear-constructor condicion condicion-simple (operador valor-referencia))

;; Genera la función para restricciones completas
(crear-constructor restriccion definicion-restriccion (nombre tipo sujeto contexto metrica regla))

;; Uso de 'slots-fijos' para indicar el operador lógico
(crear-constructor condicion-o condicion-logica (&rest sub-condiciones) :operador-logico :OR)
(crear-constructor condicion-y  condicion-logica (&rest sub-condiciones) :operador-logico :AND)
(crear-constructor condicion-no condicion-logica (sub-condicion)         :operador-logico :NOT)

;;Ejemplo horario de la facultad utilizando las funciones generadas por el macro

(defvar *horario-facultad*
  (problema-horario
    :nombre "Horario de Facultad"
    
    ;; Declaración de Entidades
    :entidades (list
                 (entidad "Turno"      '("id"))
                 (entidad "Aula"       '("id" "capacidad"))
                 (entidad "Asignatura" '("nombre" "frecuencia"))
                 (entidad "Grupo"      '("id" "asignaturas"))
                 (entidad "Profesor"   '("id" "nombre" "asignaturas")))
    
    ;; Meta de Asignación
    :asignacion (asignacion '("Asignatura" "Grupo") 
                            '("Turno" "Aula"))
    
    ;; Lista de Restricciones
    :restricciones 
    (list
      
      (restriccion "Un profesor no puede tener dos asignaturas distintas en el mismo turno"
                   "Fuerte" "Profesor" '("Turno") "Cantidad de asignaturas asignadas"
                   (condicion "<=" 1))
                     
      (restriccion "Un grupo no puede tener dos asignaturas distintas en el mismo turno"
                   "Fuerte" "Grupo" '("Turno") "Cantidad de asignaturas asignadas"
                   (condicion "<=" 1))
                     
      (restriccion "Dos grupos distintos no pueden tener la misma aula en el mismo turno"
                   "Fuerte" "Aula" '("Turno") "Cantidad de grupos distintos asignados"
                   (condicion-o (condicion "<=" 1)
                                (condicion "==" 'Asignacion.Predefinida)))
                                    
      (restriccion "A un grupo solo se le pueden asignar las asignaturas que le corresponden"
                   "Fuerte" "Asignatura (instancia a asignar)" '("Asignación a un Grupo específico") "Identidad de la asignatura"
                   (condicion "IN" 'Grupo.asignaturas))
                       
      (restriccion "La cantidad de veces que un grupo recibe una asignatura debe ser igual a la frecuencia"
                   "Fuerte" "Par (Grupo, Asignatura)" '("Todo el horario (Global)") "Conteo total de asignaciones de ese par"
                   (condicion "==" 'Asignatura.frecuencia)))))