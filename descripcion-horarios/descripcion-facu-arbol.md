Horario de Facultad
├── Entidades
│   ├── Turno
│   │   └── id
│   ├── Aula
│   │   ├── id
│   │   └── capacidad
│   ├── Asignatura
│   │   ├── nombre
│   │   └── frecuencia
│   ├── Grupo
│   │   ├── id
│   │   └── asignaturas (Lista de referencias a Asignatura)
│   └── Profesor
│       ├── id
│       ├── nombre
│       └── asignaturas (Lista de referencias a Asignatura)
├── Asignación (Meta)
│   ├── (Asignatura, Grupo) ➔ (Turno, Aula)
│   └── Nota: Grupos distintos pueden dar la misma asignatura en la misma aula
└── Restricciones Fuertes
    ├── Un profesor no puede tener dos asignaturas distintas en el mismo turno
    ├── Un grupo no puede tener dos asignaturas distintas en el mismo turno
    ├── Dos grupos distintos no pueden tener la misma aula en el mismo turno (salvo predefinición)
    ├── A un grupo solo se le pueden asignar las asignaturas que le corresponden
    └── La cantidad de veces que un grupo recibe una asignatura debe ser igual a la frecuencia de la misma

Restricciones:

Restricción: Un profesor no puede tener dos asignaturas distintas en el mismo turno
├── Tipo: Fuerte
├── Elemento Evaluado (Sujeto): Profesor
├── Espacio de Evaluación (Contexto): 
│   └── Turno
├── Elemento a Medir (Métrica): Cantidad de asignaturas asignadas
└── Regla de Validación (Condición):
    ├── Operador: Menor o igual a (<=)
    └── Valor de Referencia: 1

Restricción: Un grupo no puede tener dos asignaturas distintas en el mismo turno
├── Tipo: Fuerte
├── Elemento Evaluado (Sujeto): Grupo
├── Espacio de Evaluación (Contexto): 
│   └── Turno
├── Elemento a Medir (Métrica): Cantidad de asignaturas asignadas
└── Regla de Validación (Condición):
    ├── Operador: Menor o igual a (<=)
    └── Valor de Referencia: 1

Restricción: Dos grupos distintos no pueden tener la misma aula en el mismo turno (salvo predefinición)
├── Tipo: Fuerte
├── Elemento Evaluado (Sujeto): Aula
├── Espacio de Evaluación (Contexto): 
│   └── Turno
├── Elemento a Medir (Métrica): Cantidad de grupos distintos asignados
└── Regla de Validación (Condición Lógica OR):
    ├── Sub-Condición A (Regla General):
    │   ├── Operador: Menor o igual a (<=)
    │   └── Valor de Referencia: 1
    └── Sub-Condición B (Excepción):
        ├── Operador: Igual a (==)
        └── Valor de Referencia: Asignación.Predefinida (Verdadero)

Restricción: A un grupo solo se le pueden asignar las asignaturas que le corresponden
├── Tipo: Fuerte
├── Elemento Evaluado (Sujeto): Asignatura (instancia a asignar)
├── Espacio de Evaluación (Contexto): Asignación a un Grupo específico
├── Elemento a Medir (Métrica): Identidad de la asignatura
└── Regla de Validación (Condición):
    ├── Operador: Pertenece a la lista (IN)
    └── Valor de Referencia: Grupo.asignaturas (Lista válida)

Restricción: La cantidad de veces que un grupo recibe una asignatura debe ser igual a la frecuencia de la misma
├── Tipo: Fuerte
├── Elemento Evaluado (Sujeto): Par (Grupo, Asignatura)
├── Espacio de Evaluación (Contexto): Todo el horario (Global)
├── Elemento a Medir (Métrica): Conteo total de asignaciones de ese par
└── Regla de Validación (Condición):
    ├── Operador: Igual a (==)
    └── Valor de Referencia: Asignatura.frecuencia