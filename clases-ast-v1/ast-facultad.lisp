(defvar *horario-facultad*
  (make-instance 'problema-horario
    :nombre "Horario de Facultad"
    
    ;; 1. DECLARACIÓN DE TODAS LAS ENTIDADES
    :entidades (list
                 (make-instance 'definicion-entidad
                                :nombre "Turno"
                                :atributos '("id"))
                 
                 (make-instance 'definicion-entidad
                                :nombre "Aula"
                                :atributos '("id" "capacidad"))
                 
                 (make-instance 'definicion-entidad
                                :nombre "Asignatura"
                                :atributos '("nombre" "frecuencia"))
                 
                 (make-instance 'definicion-entidad
                                :nombre "Grupo"
                                :atributos '("id" "asignaturas")) ; Lista de referencias a Asignatura
                 
                 (make-instance 'definicion-entidad
                                :nombre "Profesor"
                                :atributos '("id" "nombre" "asignaturas"))) ; Lista de referencias a Asignatura
    
    ;; 2. META DE ASIGNACIÓN
    :asignacion (make-instance 'definicion-asignacion
                               :origen '("Asignatura" "Grupo")
                               :destino '("Turno" "Aula")
                               :notas "Grupos distintos pueden dar la misma asignatura en la misma aula")
    
    ;; 3. DECLARACIÓN DE TODAS LAS RESTRICCIONES FUERTES
    :restricciones (list
                     
                     ;; Restricción 1: Profesor único por turno
                     (make-instance 'definicion-restriccion
                       :nombre "Un profesor no puede tener dos asignaturas distintas en el mismo turno"
                       :tipo "Fuerte"
                       :sujeto "Profesor"
                       :contexto '("Turno")
                       :metrica "Cantidad de asignaturas asignadas"
                       :regla (make-instance 'condicion-simple
                                :operador "<="
                                :valor-referencia 1))
                     
                     ;; Restricción 2: Grupo único por turno
                     (make-instance 'definicion-restriccion
                       :nombre "Un grupo no puede tener dos asignaturas distintas en el mismo turno"
                       :tipo "Fuerte"
                       :sujeto "Grupo"
                       :contexto '("Turno")
                       :metrica "Cantidad de asignaturas asignadas"
                       :regla (make-instance 'condicion-simple
                                :operador "<="
                                :valor-referencia 1))
                     
                     ;; Restricción 3: Aula única por turno (Salvo predefinición - Condición Compuesta OR)
                     (make-instance 'definicion-restriccion
                       :nombre "Dos grupos distintos no pueden tener la misma aula en el mismo turno (salvo predefinición)"
                       :tipo "Fuerte"
                       :sujeto "Aula"
                       :contexto '("Turno")
                       :metrica "Cantidad de grupos distintos asignados"
                       :regla (make-instance 'condicion-logica
                                :operador-logico :OR
                                :sub-condiciones (list
                                                   ;; Sub-Condición A: Regla General
                                                   (make-instance 'condicion-simple
                                                     :operador "<="
                                                     :valor-referencia 1)
                                                   ;; Sub-Condición B: Excepción
                                                   (make-instance 'condicion-simple
                                                     :operador "=="
                                                     :valor-referencia 'Asignacion.Predefinida))))
                     
                     ;; Restricción 4: Pertenencia de asignaturas del grupo
                     (make-instance 'definicion-restriccion
                       :nombre "A un grupo solo se le pueden asignar las asignaturas que le corresponden"
                       :tipo "Fuerte"
                       :sujeto "Asignatura (instancia a asignar)"
                       :contexto '("Asignación a un Grupo específico")
                       :metrica "Identidad de la asignatura"
                       :regla (make-instance 'condicion-simple
                                :operador "IN"
                                :valor-referencia 'Grupo.asignaturas))
                     
                     ;; Restricción 5: Frecuencia obligatoria de la asignatura
                     (make-instance 'definicion-restriccion
                       :nombre "La cantidad de veces que un grupo recibe una asignatura debe ser igual a la frecuencia de la misma"
                       :tipo "Fuerte"
                       :sujeto "Par (Grupo, Asignatura)"
                       :contexto '("Todo el horario (Global)")
                       :metrica "Conteo total de asignaciones de ese par"
                       :regla (make-instance 'condicion-simple
                                :operador "=="
                                :valor-referencia 'Asignatura.frecuencia)))))