1. Nodos Base y Declaraciones de Estructura

Todos los elementos derivarán de una clase base (ej. `NodoAST`). A partir de ahí, se define el modelo de datos.

* `DefinicionEntidad`
Propósito: Representa los conceptos principales (Profesor, Aula, Programa, Tesis).
Atributos (Slots):
    - `nombre`: El identificador de la entidad.
    - `caracteristicas`: Una lista de objetos tipo `Atributo`.


* `Atributo` (Clase abstracta o padre para las características)
* `AtributoPrimitivo`: Para valores directos (ej. `nombre`, `capacidad`).
* `AtributoEnumerado`: Para listas de valores cerrados (ej. `[lic., Msc., Dr.]`).
* `AtributoDerivado`: Para valores que se calculan (ej. `hora_fin = hora_inicio + duracion`).
* `Relacion`: Para referencias a otras entidades. Puede ser simple (un `tutor` apunta a un `Profesor`) o múltiple (unas `asignaturas` apuntan a una lista de `Asignatura`).


### 2. Definición del Objetivo del Problema

Qué dominios está cruzando para generar las soluciones.

* `Asignacion`
Propósito: Representa la operación `➔` (el "qué" se asigna a "dónde").
Atributos (Slots):
    - `recursos`: Lista de entidades a asignar (ej. `Tesis`, o el par `[Asignatura, Grupo]`).
    - `dimensiones`: Lista de entidades que forman el espacio de destino (ej. `[Local, Día, Hora]`).


### 3. Componentes de las Restricciones

* **`Restriccion`**
Propósito: Agrupa la regla completa.
Atributos (Slots):
    - `tipo`: Fuerte (hard) o Débil (soft).
    - `sujeto`: Una instancia de `SujetoEvaluado`.
    - `contexto`: Una instancia de `ContextoEvaluacion`.
    - `metrica`: Una instancia de `Metrica`.
    - `condicion`: Una instancia de `Condicion`.





Clases para restricción:

* `SujetoEvaluado`
Propósito: Define sobre quién recae la regla.
Atributos:
    - `entidades`: Puede ser una sola entidad (ej. `Profesor`) o una tupla/par de entidades (ej. `[Grupo, Asignatura]`).


* `ContextoEvaluacion`
Propósito: Define el "dónde" o "cuándo" se aplica la regla.
Atributos:
    - `dimensiones`: Entidades espaciales o temporales (ej. `Turno`, `Canal`, `Día`, `Hora`).
    - `alcance`: Puede ser `Adyacente` (para la TV, evaluando el bloque anterior/siguiente) o `Global` (para la frecuencia semanal de la facultad).


* `Metrica` (Clase abstracta)
* `MetricaConteo`: Cuenta ocurrencias de una entidad en el contexto (ej. cantidad de tesis asignadas, cantidad de asignaturas).
* `MetricaAtributo`: Extrae una característica específica (ej. `tipo_de_programa`, la identidad de la `Asignatura`).


* `Condicion` (Clase abstracta, permite recursividad)

* `CondicionSimple`:
    - `operador`: `<=`, `==`, `!=`, `PERTENECE_A` (IN).
    - `valor_referencia`: Contra qué se compara. Puede ser un literal (`1`), la propiedad de otra entidad (`Asignatura.frecuencia`), o el estado del nodo anterior (`Programa_Anterior.tipo_de_programa`).

* `CondicionCompuesta`: (ej restricción de aulas predefinidas)
    - `operador_logico`: `Y` (AND), `O` (OR).
    - `subcondiciones`: Lista de instancias de `Condicion` (ej. Sub-condición A *O* Sub-condición B).
