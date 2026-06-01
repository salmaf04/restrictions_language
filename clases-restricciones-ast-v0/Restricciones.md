Listas de entrada (lenguaje neutro):
- H: Lista de tuplas (grupo, dia, turno, asignatura, aula)
- F: Lista de (grupo, asignatura, frecuencia)
- P: Mapeo de asignatura -> profesor
- M: La tabla de "cosas que se pueden mezclar" (lista de listas donde asignatura está en la posición 0 y en el resto los grupos)

Función Objetivo:
$$Vprof + Vgrup + Vaula + Vscope + Vfreq$$

Validación de profesor: "Un mismo profesor no puede tener dos asignaturas distintas en el mismo turno."
- Agrupar lista H por día y turno
- Ir por cada grupo de día/turno viendo las asignaturas programadas, verificar en la lista P si hay dos asignaturas que tienen un mismo profesor.
- Sumar 1 a Vprof cada vez que aparezca un profesor duplicado

Validación grupos: "Un grupo no puede tener dos asignaturas distintas en el mismo turno."
- Agrupar lista H por día y turno
- Ir por cada grupo de día/turno viendo los grupos
- Si un grupo aparece más de una vez Vgrupo +1

Validación de aulas: "Dos grupos distintos no pueden tener la misma aula... a no ser que estén en la tabla de mezclas."
- Agrupar H por Día, Turno y Aula.
- Si en una tupla (Dia, Turno, Aula) hay más de un grupo:
    - Verificar si la Asignatura es la misma para todos. Si son asignaturas distintas Vaula +1
    - Si la asignatura es la misma, buscar esa asignatura en la tabla $M$ (Mezclas).
    - Verificar si TODOS los grupos presentes en esa aula están listados en la fila correspondiente de esa asignatura en M.
    - Si algún grupo no pertenece a la lista permitida Vaula +1.

Validación de Scope: "Solo pueden existir asignaturas de la tabla asignaturas de esa misma hoja G."
- Agrupar H por Grupo.
- Agrupar F por Grupo.
- Verificar si cada asignatura de un Grupo en H, existe en la lista F para ese grupo
- Si no existe +1 Vscope

Validación de frecuencia: "La cantidad de veces que una asignatura aparece... tiene que ser igual a la frecuencia."
- Calcular frecuencia actual en la tabla H cuantas veces aparece una asignatura para un grupo.
- Ver Frecuencia Objetivo por la lista F (grupo, asignatura, frecuencia).
- Calcular diferencia absoluta entre frecuencia objetivo y frecuencia actual.
- Sumar dicha doferencia a  Vfreq.

Elementos del lenguaje:
- Foreach
- If
- +
- Abs
- Group by 
- Unique: verificar si un elemento es unico
- Count: cuantas veces esta cada elemento en una lista
- map: dado una key verificar su valor en un diccionario
- contain: ver si un elemento existe en una tabla o lista
- subset: verificar si una lista de elementos esta contenida dentro de otra
- Entidades

Validación de profesor: "Un mismo profesor no puede tener dos asignaturas distintas en el mismo turno."
- Group by H.día && H.turno
- list professors
- Foreach (grupo dia turno) agregar a professors el valor de la asignatura en el diccionario profesores (map)
- Counr (professors)
- Los que esten mas de una vez se suma a la cantidad de errores la cantidad de veces que este repetido 

Validación grupos: "Un grupo no puede tener dos asignaturas distintas en el mismo turno."
- Group by H.día && H.turno
- list groups
- Foreach (grupo dia turno) agregar a groups el grupo
- Counr (group)
- Los que esten mas de una vez se suma a la cantidad de errores la cantidad de veces que este repetido 

Validación de aulas: "Dos grupos distintos no pueden tener la misma aula... a no ser que estén en la tabla de mezclas."
- Group by H.día && H.turno && H.aula
- if en un grupo de dia/turno/aula .length >= 1
    - lista <subjects, group>
    - foreach (grupo dia/turno/aula) 
        - if subjects.length > 0 && !(subject.contain(asignatura)) 
            - agregar un error 
        - agregar tupla asignatura grupo
         
    - Group by subject
    - Foreach (subject)
        - lista con los grupos
        - if !(esta lista es Subset de la lista asociada a la asignatura en la tabla mezcla) sumar error

Validación de Scope: "Solo pueden existir asignaturas de la tabla asignaturas de esa misma hoja G."
- Group by H.grupo
- Group by F.grupo
- Foreach (grupo de H)
    lista asignaturas = asignaturas asociadas al grupo en F.
    - Foreach (asignatura del grupo) 
        - if !(asignatura contain asignatura del grupo) sumar uno al error

Validación de frecuencia: "La cantidad de veces que una asignatura aparece... tiene que ser igual a la frecuencia."
- Group by H.asignatura H.grupo
- Foreach (grupo de asignatura grupo)
    - Group by F.asignatura F.grupo
    - diferencia = ABS (grupo de asignatura grupo - frecuencia)
    - if diferencia != 0 sumar diferencia al error.
