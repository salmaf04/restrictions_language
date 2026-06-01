Horario de Tesis
├── Entidades
│   ├── Grados Permitidos: [lic., Msc., Dr.]
│   ├── Días Permitidos: [1/6, 2/6, 3/6]
│   ├── Horas Permitidas: [9am, 11am, 1pm, 3pm]
│   ├── Profesor
│   │   ├── id
│   │   ├── nombre
│   │   └── grado
│   ├── Estudiante
│   │   ├── id
│   │   └── nombre
│   ├── Tesis
│   │   ├── id
│   │   ├── estudiante (Referencia a Estudiante)
│   │   ├── tutor (Referencia a Profesor)
│   │   ├── oponente (Referencia a Profesor)
│   │   ├── presidente (Referencia a Profesor)
│   │   ├── secretario (Referencia a Profesor)
│   │   └── vocal (Referencia a Profesor)
│   └── Local
│       └── nombre
├── Asignación (Meta)
│   └── Tesis ➔ (Local, Día, Hora)
├── Restricciones Fuertes
│   └── Un profesor no puede estar en dos tesis el mismo día a la misma hora


Restricciones:

Restricción: Un profesor no puede estar en dos tesis el mismo día a la misma hora
├── Tipo: Fuerte
├── Elemento Evaluado (Sujeto): Profesor
├── Espacio de Evaluación (Contexto): 
│   ├── Día
│   └── Hora
├── Elemento a Medir (Métrica): Cantidad de tesis asignadas
└── Regla de Validación (Condición):
    ├── Operador: Menor o igual a (<=)
    └── Valor de Referencia: 1