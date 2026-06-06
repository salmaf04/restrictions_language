# -*- coding: utf-8 -*-
# Generado automaticamente desde el AST

import sys, copy, random
from dataclasses import dataclass, field
from typing import List

# Forzar UTF-8 para poder mostrar simbolos matematicos
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')


# ============================================================
# ENTIDADES DEL DOMINIO
# ============================================================

@dataclass(unsafe_hash=True)
class Tiene_Nombre:
    nombre: object = None
    def __str__(self): return str(self.nombre)

@dataclass(unsafe_hash=True)
class Grado:
    id: object = None
    def __str__(self): return str(self.id)

@dataclass(unsafe_hash=True)
class Profesor:
    nombre: object = None
    grado: object = None
    def __str__(self): return str(self.nombre)

@dataclass(unsafe_hash=True)
class Estudiante:
    nombre: object = None
    def __str__(self): return str(self.nombre)

@dataclass(unsafe_hash=True)
class Tribunal:
    estudiante: object = None
    tutor: object = None
    oponente: object = None
    presidente: object = None
    vocal: object = None
    secretario: object = None
    def __str__(self): return f'(estudiante={self.estudiante}, tutor={self.tutor}, oponente={self.oponente}, presidente={self.presidente}, vocal={self.vocal}, secretario={self.secretario})'

@dataclass(unsafe_hash=True)
class Fecha:
    dia: object = None
    mes: object = None
    def __str__(self): return f'(dia={self.dia}, mes={self.mes})'

@dataclass(unsafe_hash=True)
class Momento:
    hora: object = None
    def __str__(self): return str(self.hora)

@dataclass(unsafe_hash=True)
class Local:
    nombre: object = None
    def __str__(self): return str(self.nombre)

@dataclass
class Asignacion:
    tribunal: object = None
    fecha: object = None
    momento: object = None
    local: object = None

@dataclass
class Horario:
    asignacion: List = field(default_factory=list)
    profesor: List = field(default_factory=list)



# ============================================================
# CONSULTAS
# ============================================================

def conflictos_de_horario(horario):
    count = 0
    for p in horario.profesor:
        for a1 in horario.asignacion:
            for a2 in horario.asignacion:
                if (((a1.tribunal.tutor == p) or (a1.tribunal.oponente == p) or (a1.tribunal.presidente == p) or (a1.tribunal.vocal == p) or (a1.tribunal.secretario == p)) and ((a2.tribunal.tutor == p) or (a2.tribunal.oponente == p) or (a2.tribunal.presidente == p) or (a2.tribunal.vocal == p) or (a2.tribunal.secretario == p)) and (a1.fecha == a2.fecha) and (a1.momento == a2.momento) and (a1.tribunal != a2.tribunal)):
                    count += 1
    return count

def dias_asistidos(horario, prof):
    dias = set()
    for asig in horario.asignacion:
        if ((asig.tribunal.tutor == prof) or (asig.tribunal.oponente == prof) or (asig.tribunal.presidente == prof) or (asig.tribunal.vocal == prof) or (asig.tribunal.secretario == prof)):
            dias.add(asig.fecha)
    return len(dias)

# ============================================================
# RESTRICCIONES SIMPLES / DURAS  (nppq / tqpq)
# Cada función devuelve el numero de veces que se incumple.
# ============================================================

# SIMPLE / DURA  (nppq) — No Puede Pasar Que
def restriccion_sin_conflictos_de_horario(horario):
    return conflictos_de_horario(horario)

# ============================================================
# RESTRICCIONES DEBILES / BLANDAS  (tdpq / sbqp)
# Cada función devuelve el numero de veces que se incumple.
# ============================================================

# OPTIMIZACIÓN — Minimizar
def restriccion_minimizar_carga_maxima(horario):
    valores = [dias_asistidos(horario, x) for x in horario.profesor]
    return max(valores) if valores else 0

# ============================================================
# MODELO MATEMATICO
#   costo = PESO_DURA   * sum(violaciones duras)
#         + PESO_BLANDA * sum(violaciones blandas)
# ============================================================

PESO_DURA   = 1000
PESO_BLANDA = 1

def evaluar(horario):
    costo = 0
    # restricciones simples / duras
    costo += PESO_DURA   * restriccion_sin_conflictos_de_horario(horario)
    # restricciones debiles / blandas
    costo += PESO_BLANDA * restriccion_minimizar_carga_maxima(horario)
    return costo


def mostrar_modelo():
    """Imprime el modelo abstracto de optimizacion."""
    sep = '=' * 60
    print(sep)
    print('MODELO DE OPTIMIZACION')
    print(sep)
    print()
    print('INDICES Y CONJUNTOS:')
    print(f'  T  =  conjunto de tribunals      (|T| = {len(TRIBUNALS)})')
    print(f'  F  =  conjunto de fecha disponibles   (|F| = {len(POOL_FECHA)})')
    print(f'  M  =  conjunto de momento disponibles   (|M| = {len(POOL_MOMENTO)})')
    print(f'  L  =  conjunto de local disponibles   (|L| = {len(POOL_LOCAL)})')
    print(f'  P  =  conjunto de profesor   (|P| = {len(PROFESOR)})')
    print()
    print('VARIABLES DE DECISION:')
    print('  Para cada tribunal t ∈ T se asigna:')
    print('    fecha_t ∈ F   (fecha)')
    print('    momento_t ∈ M   (momento)')
    print('    local_t ∈ L   (local)')
    print()
    print('FUNCION OBJETIVO:')
    print('  minimizar z(h) donde:')
    print('    z(h) = 1000 · Σ_i incumpl_i(h)   [duras]')
    print('         + 1 · Σ_j incumpl_j(h)   [blandas]')
    print()
    print('RESTRICCIONES DURAS  (nppq / tqpq):')
    print('  R1  [SIMPLE / DURA  (nppq) — No Puede Pasar Que]:')
    print('    conflictos_de_horario(h) = 0')
    print('    donde:')
    print('      conflictos_de_horario(h) = Σ_{p∈PROFESOR, a1∈ASIGNACION, a2∈ASIGNACION}  [(((tutor(tribunal(a1)) = p) ∨ (oponente(tribunal(a1)) = p) ∨ (presidente(tribunal(a1)) = p) ∨ (vocal(tribunal(a1)) = p) ∨ (secretario(tribunal(a1)) = p)) ∧ ((tutor(tribunal(a2)) = p) ∨ (oponente(tribunal(a2)) = p) ∨ (presidente(tribunal(a2)) = p) ∨ (vocal(tribunal(a2)) = p) ∨ (secretario(tribunal(a2)) = p)) ∧ (fecha(a1) = fecha(a2)) ∧ (momento(a1) = momento(a2)) ∧ (tribunal(a1) ≠ tribunal(a2)))]')
    print()
    print()
    print('RESTRICCIONES BLANDAS  (tdpq / sbqp / minimizar):')
    print('  R2  [OPTIMIZACIÓN — Minimizar]:')
    print('    minimizar  max_{{x ∈ PROFESOR}}  dias_asistidos(h, x)')
    print('    donde:')
    print('      dias_asistidos(h, prof) = |{ fecha(asig) : asig∈ASIGNACION,  ((tutor(tribunal(asig)) = prof) ∨ (oponente(tribunal(asig)) = prof) ∨ (presidente(tribunal(asig)) = prof) ∨ (vocal(tribunal(asig)) = prof) ∨ (secretario(tribunal(asig)) = prof)) }|')
    print()
    print()
    print(sep)


def mostrar_resultado(horario):
    """Imprime el horario decidido y cuantas restricciones se incumplen."""
    sep = '=' * 60
    print(sep)
    print('HORARIO PROPUESTO POR LA METAHEURISTICA')
    print(sep)
    print()
    for i, asig in enumerate(horario.asignacion, 1):
        print(f'  Defensa {i}:')
        print(f'    TRIBUNAL : {asig.tribunal}')
        print(f'    FECHA : {asig.fecha}')
        print(f'    MOMENTO : {asig.momento}')
        print(f'    LOCAL : {asig.local}')
        print()
    print(sep)
    print('EVALUACION DE RESTRICCIONES')
    print(sep)
    costo_total = 0
    print('Restricciones simples / duras  (peso 1000):')
    v = restriccion_sin_conflictos_de_horario(horario)
    costo_total += PESO_DURA * v
    print(f'  restriccion_sin_conflictos_de_horario: {v} incumplimientos  ->  costo: {PESO_DURA * v}')
    print('Restricciones debiles / blandas  (peso 1):')
    v = restriccion_minimizar_carga_maxima(horario)
    costo_total += PESO_BLANDA * v
    print(f'  restriccion_minimizar_carga_maxima: {v}  ->  costo: {PESO_BLANDA * v}')
    print(f'Costo total: {costo_total}')
    print(sep)


# ============================================================
# ALGORITMO GENETICO
# ============================================================

POP_SIZE      = 100
GENERACIONES  = 500
PROB_CRUCE    = 0.8
PROB_MUTACION = 0.15
TORNEO_K      = 5

def crear_horario_aleatorio(tribunals, pool_fecha, pool_momento, pool_local, profesor):
    """Crea un horario asignando recursos aleatorios a cada tribunal."""
    h = Horario()
    h.profesor = list(profesor)
    for ident in tribunals:
        h.asignacion.append(Asignacion(
            tribunal=ident,
            fecha=random.choice(pool_fecha),
            momento=random.choice(pool_momento),
            local=random.choice(pool_local),
        ))
    return h

def crear_poblacion(tribunals, pool_fecha, pool_momento, pool_local, profesor, tamanio=POP_SIZE):
    return [crear_horario_aleatorio(tribunals, pool_fecha, pool_momento, pool_local, profesor) for _ in range(tamanio)]

def seleccion_torneo(poblacion, k=TORNEO_K):
    """Devuelve el mejor de k individuos elegidos al azar."""
    candidatos = random.sample(poblacion, min(k, len(poblacion)))
    return min(candidatos, key=evaluar)

def cruce(p1, p2):
    """Cruce de un punto: intercambia recursos (fecha, momento, local) tras el corte."""
    n = len(p1.asignacion)
    if n < 2:
        return copy.deepcopy(p1), copy.deepcopy(p2)
    corte = random.randint(1, n - 1)
    h1 = copy.deepcopy(p1)
    h2 = copy.deepcopy(p2)
    for i in range(corte, n):
        h1.asignacion[i].fecha, h2.asignacion[i].fecha = h2.asignacion[i].fecha, h1.asignacion[i].fecha
        h1.asignacion[i].momento, h2.asignacion[i].momento = h2.asignacion[i].momento, h1.asignacion[i].momento
        h1.asignacion[i].local, h2.asignacion[i].local = h2.asignacion[i].local, h1.asignacion[i].local
    return h1, h2

def mutar(individuo, pool_fecha, pool_momento, pool_local, prob=PROB_MUTACION):
    """Reasigna aleatoriamente un recurso de un tribunal al azar."""
    if random.random() >= prob:
        return individuo
    nuevo = copy.deepcopy(individuo)
    items = nuevo.asignacion
    if not items:
        return nuevo
    item  = random.choice(items)
    campo = random.choice(("fecha" "momento" "local"))
    if campo == "fecha": item.fecha = random.choice(pool_fecha)
    if campo == "momento": item.momento = random.choice(pool_momento)
    if campo == "local": item.local = random.choice(pool_local)
    return nuevo

def algoritmo_genetico(tribunals, pool_fecha, pool_momento, pool_local, profesor,
                       tamanio_pob=POP_SIZE,
                       generaciones=GENERACIONES):
    """
    Genera y optimiza un horario que minimiza las restricciones
    incumplidas. Devuelve (mejor_horario, costo_final).
    """
    poblacion   = crear_poblacion(tribunals, pool_fecha, pool_momento, pool_local, profesor, tamanio_pob)
    mejor       = min(poblacion, key=evaluar)
    mejor_costo = evaluar(mejor)
    print(f'Generacion  0: costo inicial = {mejor_costo}')

    for gen in range(generaciones):
        nueva_pob = [copy.deepcopy(mejor)]  # elitismo
        while len(nueva_pob) < tamanio_pob:
            p1 = seleccion_torneo(poblacion)
            p2 = seleccion_torneo(poblacion)
            if random.random() < PROB_CRUCE:
                h1, h2 = cruce(p1, p2)
            else:
                h1, h2 = copy.deepcopy(p1), copy.deepcopy(p2)
            nueva_pob.append(mutar(h1, pool_fecha, pool_momento, pool_local))
            if len(nueva_pob) < tamanio_pob:
                nueva_pob.append(mutar(h2, pool_fecha, pool_momento, pool_local))
        poblacion   = nueva_pob
        candidato   = min(poblacion, key=evaluar)
        costo_c     = evaluar(candidato)
        if costo_c < mejor_costo:
            mejor       = candidato
            mejor_costo = costo_c
        if (gen + 1) % 50 == 0 or mejor_costo == 0:
            print(f'Generacion {gen + 1:>4}: mejor costo = {mejor_costo}')
        if mejor_costo == 0:
            print('Solucion perfecta encontrada.')
            break

    return mejor, mejor_costo


# ============================================================
# DATOS DEL DOMINIO (constantes de módulo)
# ============================================================

# tribunals
TRIBUNALS = [
    Tribunal(estudiante=Estudiante(nombre="Laura Rodriguez"), tutor=Profesor(nombre="Alejandro Piad", grado=Grado(id="Dr")), oponente=Profesor(nombre="Carlos Suarez", grado=Grado(id="Msc")), presidente=Profesor(nombre="Maria Garcia", grado=Grado(id="Dr")), vocal=Profesor(nombre="Luis Torres", grado=Grado(id="Msc")), secretario=Profesor(nombre="Ana Mendez", grado=Grado(id="Dr"))),
    Tribunal(estudiante=Estudiante(nombre="Carlos Fernandez"), tutor=Profesor(nombre="Maria Garcia", grado=Grado(id="Dr")), oponente=Profesor(nombre="Pedro Herrera", grado=Grado(id="Msc")), presidente=Profesor(nombre="Alejandro Piad", grado=Grado(id="Dr")), vocal=Profesor(nombre="Carlos Suarez", grado=Grado(id="Msc")), secretario=Profesor(nombre="Luis Torres", grado=Grado(id="Msc"))),
    Tribunal(estudiante=Estudiante(nombre="Sofia Lopez"), tutor=Profesor(nombre="Ana Mendez", grado=Grado(id="Dr")), oponente=Profesor(nombre="Luis Torres", grado=Grado(id="Msc")), presidente=Profesor(nombre="Carlos Suarez", grado=Grado(id="Msc")), vocal=Profesor(nombre="Pedro Herrera", grado=Grado(id="Msc")), secretario=Profesor(nombre="Maria Garcia", grado=Grado(id="Dr"))),
]

# pool de fecha
POOL_FECHA = [
    Fecha(dia=1, mes=6),
    Fecha(dia=2, mes=6),
    Fecha(dia=3, mes=6),
]

# pool de momento
POOL_MOMENTO = [
    Momento(hora=9),
    Momento(hora=11),
    Momento(hora=14),
]

# pool de local
POOL_LOCAL = [
    Local(nombre="Sala A"),
    Local(nombre="Sala B"),
]

# profesor
PROFESOR = [
    Profesor(nombre="Alejandro Piad", grado=Grado(id="Dr")),
    Profesor(nombre="Carlos Suarez", grado=Grado(id="Msc")),
    Profesor(nombre="Maria Garcia", grado=Grado(id="Dr")),
    Profesor(nombre="Luis Torres", grado=Grado(id="Msc")),
    Profesor(nombre="Ana Mendez", grado=Grado(id="Dr")),
    Profesor(nombre="Pedro Herrera", grado=Grado(id="Msc")),
]

# ============================================================
# PUNTO DE ENTRADA
# ============================================================

if __name__ == '__main__':
    mostrar_modelo()

    solucion, costo = algoritmo_genetico(TRIBUNALS, POOL_FECHA, POOL_MOMENTO, POOL_LOCAL, PROFESOR)

    print()
    mostrar_resultado(solucion)
