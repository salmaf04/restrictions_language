Horario Facultad 

- un turno tiene un id
- un aula tiene: 
    - id
    - capacidad 
- una asignatura tiene:
    - nombre
    - frecuencia
- un grupo tiene:
    - id
    - asignaturas
- un profesor tiene: 
    - id 
    - nombre
    - asignaturas

- nos interesa asociar asignatura con grupo con turno y con aula
- existen grupos que pueden dar en la misma aula una misma asignatura

Restricciones fuertes:
- Un mismo profesor no puede tener dos asignaturas distintas en el mismo turno.
- Un grupo no puede tener dos asignaturas distintas en el mismo turno.
- Dos grupos distintos no pueden tener la misma aula en el mismo turno a no ser que esté predefino. 
- A un grupo solo se le puede asignar las asignaturas que le corresponde.
- La cantidad de veces que un grupo recibe una asignatura debe ser igual a la frecuencia de esta asignatura.
