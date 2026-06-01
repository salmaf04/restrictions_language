Horario de TV
├── Entidades
│   ├── Programa
│   │   ├── id
│   │   ├── nombre
│   │   ├── tipo de programa
│   │   └── tipo de público
│   ├── Canal
│   │   ├── id
│   │   ├── nombre
│   │   ├── días de transmisión
│   │   └── programas (Lista de referencias a Programa)
│   └── Bloque de Emisión (Hora)
│       ├── id
│       ├── programa (Referencia a Programa)
│       ├── duración
│       ├── hora de inicio (Calculada: = hora de fin del programa anterior, excepto el primero)
│       └── hora de fin (Calculada: = hora de inicio + duración)
├── Asignación (Meta)
│   └── Programa ➔ (Bloque de Emisión, Día de transmisión)
└── Restricciones Fuertes
    └── No deben existir dos programas seguidos del mismo tipo

Restricciones:
Restricción: No deben existir dos programas seguidos del mismo tipo
├── Tipo: Fuerte
├── Elemento Evaluado (Sujeto): Programa actual (Programa N)
├── Espacio de Evaluación (Contexto): 
│   ├── Canal
│   └── Orden adyacente (Bloque temporal inmediato anterior)
├── Elemento a Medir (Métrica): 'tipo_de_programa' del Programa N
└── Regla de Validación (Condición):
    ├── Operador: Diferente de (!=)
    └── Valor de Referencia: 'tipo_de_programa' del Programa N-1