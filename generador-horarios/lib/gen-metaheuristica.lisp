;; === gen-metaheuristica.lisp — Generación del algoritmo genético ===
;; Genera el código Python completo del algoritmo genético (GA):
;;   generar-algoritmo-genetico
;;
;; Parámetros:
;;   id-const    — nombre de la constante de identidades (UPPERCASE), ej. "TRIBUNALES"
;;   pool-consts — nombres de constantes pool (UPPERCASE), ej. ("POOL_FECHA" ...)
;;   otros-consts — nombres de constantes de otros dominios (UPPERCASE), ej. ("PROFESORES")

(defun generar-algoritmo-genetico (entidad-horario slot-identidad slots-variables
                                   otros-dominios
                                   id-const pool-consts otros-consts
                                   stream)
  (let* ((ent-py    (py-nombre entidad-horario))
         (id-py     (py-nombre slot-identidad))
         (vars-py   (mapcar #'py-nombre slots-variables))
         (otros-py  (mapcar #'py-nombre otros-dominios))
         ;; Nombre de la clase Python de la entidad combinación
         (ent-clase (string-capitalize ent-py))
         ;; Parámetros de la firma del GA: con nombres en minúsculas
         (id-var    (string-downcase id-const))
         (pool-vars (mapcar #'string-downcase pool-consts))
         (otros-vars (mapcar #'string-downcase otros-consts))
         ;; Firma: id_var, pool_var1, ..., otro1, ...
         (ga-params (format nil "~{~a~^, ~}"
                            (append (list id-var) pool-vars otros-vars))))

    (format stream "# ============================================================~%")
    (format stream "# ALGORITMO GENETICO~%")
    (format stream "# ============================================================~%~%")

    ;; Parámetros del GA
    (format stream "POP_SIZE      = 100~%")
    (format stream "GENERACIONES  = 500~%")
    (format stream "PROB_CRUCE    = 0.8~%")
    (format stream "PROB_MUTACION = 0.15~%")
    (format stream "TORNEO_K      = 5~%~%")

    ;; crear_horario_aleatorio
    (format stream "def crear_horario_aleatorio(~a):~%" ga-params)
    (format stream "    \"\"\"Crea un horario asignando recursos aleatorios a cada ~a.\"\"\"~%"
            id-py)
    (format stream "    h = Horario()~%")
    (dolist (otro otros-py)
      (format stream "    h.~a = list(~a)~%" otro otro))
    (format stream "    for ident in ~a:~%" id-var)
    (format stream "        h.~a.append(~a(~%"
            ent-py ent-clase)
    (format stream "            ~a=ident,~%" id-py)
    (dolist (pair (mapcar #'cons vars-py pool-vars))
      (format stream "            ~a=random.choice(~a),~%" (car pair) (cdr pair)))
    (format stream "        ))~%")
    (format stream "    return h~%~%")

    ;; crear_poblacion
    (format stream "def crear_poblacion(~a, tamanio=POP_SIZE):~%" ga-params)
    (format stream "    return [crear_horario_aleatorio(~a) for _ in range(tamanio)]~%~%"
            ga-params)

    ;; seleccion_torneo
    (format stream "def seleccion_torneo(poblacion, k=TORNEO_K):~%")
    (format stream "    \"\"\"Devuelve el mejor de k individuos elegidos al azar.\"\"\"~%")
    (format stream "    candidatos = random.sample(poblacion, min(k, len(poblacion)))~%")
    (format stream "    return min(candidatos, key=evaluar)~%~%")

    ;; cruce — solo intercambia los slots variables en cada posición (el id es fijo)
    (format stream "def cruce(p1, p2):~%")
    (format stream "    \"\"\"Cruce de un punto: intercambia recursos (~{~a~^, ~}) tras el corte.\"\"\"~%"
            vars-py)
    (format stream "    n = len(p1.~a)~%" ent-py)
    (format stream "    if n < 2:~%")
    (format stream "        return copy.deepcopy(p1), copy.deepcopy(p2)~%")
    (format stream "    corte = random.randint(1, n - 1)~%")
    (format stream "    h1 = copy.deepcopy(p1)~%")
    (format stream "    h2 = copy.deepcopy(p2)~%")
    (format stream "    for i in range(corte, n):~%")
    (dolist (v vars-py)
      (format stream "        h1.~a[i].~a, h2.~a[i].~a = h2.~a[i].~a, h1.~a[i].~a~%"
              ent-py v ent-py v ent-py v ent-py v))
    (format stream "    return h1, h2~%~%")

    ;; mutar — cambia un slot variable de un elemento aleatorio
    (let ((pool-sig (format nil "~{~a~^, ~}" pool-vars)))
      (format stream "def mutar(individuo, ~a, prob=PROB_MUTACION):~%" pool-sig)
      (format stream "    \"\"\"Reasigna aleatoriamente un recurso de un ~a al azar.\"\"\"~%" id-py)
      (format stream "    if random.random() >= prob:~%")
      (format stream "        return individuo~%")
      (format stream "    nuevo = copy.deepcopy(individuo)~%")
      (format stream "    items = nuevo.~a~%" ent-py)
      (format stream "    if not items:~%")
      (format stream "        return nuevo~%")
      (format stream "    item  = random.choice(items)~%")
      (format stream "    campo = random.choice(~s)~%" vars-py)
      (dolist (pair (mapcar #'cons vars-py pool-vars))
        (format stream "    if campo == ~s: item.~a = random.choice(~a)~%"
                (car pair) (car pair) (cdr pair)))
      (format stream "    return nuevo~%~%"))

    ;; algoritmo_genetico principal
    (let ((mut-call (format nil "mutar(h1, ~{~a~^, ~})" pool-vars))
          (mut-call2 (format nil "mutar(h2, ~{~a~^, ~})" pool-vars)))
      (format stream "def algoritmo_genetico(~a,~%" ga-params)
      (format stream "                       tamanio_pob=POP_SIZE,~%")
      (format stream "                       generaciones=GENERACIONES):~%")
      (format stream "    \"\"\"~%")
      (format stream "    Genera y optimiza un horario que minimiza las restricciones~%")
      (format stream "    incumplidas. Devuelve (mejor_horario, costo_final).~%")
      (format stream "    \"\"\"~%")
      (format stream "    poblacion   = crear_poblacion(~a, tamanio_pob)~%" ga-params)
      (format stream "    mejor       = min(poblacion, key=evaluar)~%")
      (format stream "    mejor_costo = evaluar(mejor)~%")
      (format stream "    print(f'Generacion  0: costo inicial = {mejor_costo}')~%~%")
      (format stream "    for gen in range(generaciones):~%")
      (format stream "        nueva_pob = [copy.deepcopy(mejor)]  # elitismo~%")
      (format stream "        while len(nueva_pob) < tamanio_pob:~%")
      (format stream "            p1 = seleccion_torneo(poblacion)~%")
      (format stream "            p2 = seleccion_torneo(poblacion)~%")
      (format stream "            if random.random() < PROB_CRUCE:~%")
      (format stream "                h1, h2 = cruce(p1, p2)~%")
      (format stream "            else:~%")
      (format stream "                h1, h2 = copy.deepcopy(p1), copy.deepcopy(p2)~%")
      (format stream "            nueva_pob.append(~a)~%" mut-call)
      (format stream "            if len(nueva_pob) < tamanio_pob:~%")
      (format stream "                nueva_pob.append(~a)~%" mut-call2)
      (format stream "        poblacion   = nueva_pob~%")
      (format stream "        candidato   = min(poblacion, key=evaluar)~%")
      (format stream "        costo_c     = evaluar(candidato)~%")
      (format stream "        if costo_c < mejor_costo:~%")
      (format stream "            mejor       = candidato~%")
      (format stream "            mejor_costo = costo_c~%")
      (format stream "        if (gen + 1) % 50 == 0 or mejor_costo == 0:~%")
      (format stream "            print(f'Generacion {gen + 1:>4}: mejor costo = {mejor_costo}')~%")
      (format stream "        if mejor_costo == 0:~%")
      (format stream "            print('Solucion perfecta encontrada.')~%")
      (format stream "            break~%~%")
      (format stream "    return mejor, mejor_costo~%~%~%"))

    ;; ── Datos como constantes de módulo (accesibles por mostrar_modelo) ──
    (format stream "# ============================================================~%")
    (format stream "# DATOS DEL DOMINIO (constantes de módulo)~%")
    (format stream "# ============================================================~%~%")

    ;; Identidades
    (format stream "# ~as~%" id-py)
    (emitir-lista-py id-const slot-identidad stream "")
    (format stream "~%")
    ;; Pools de recursos
    (dolist (pair (mapcar #'cons pool-consts slots-variables))
      (let ((cst (car pair)) (ent (cdr pair)))
        (format stream "# pool de ~a~%" (py-nombre ent))
        (emitir-lista-py cst ent stream "")
        (format stream "~%")))
    ;; Otros dominios
    (dolist (pair (mapcar #'cons otros-consts otros-dominios))
      (let ((cst (car pair)) (ent (cdr pair)))
        (format stream "# ~a~%" (py-nombre ent))
        (emitir-lista-py cst ent stream "")
        (format stream "~%")))

    ;; ── Punto de entrada ─────────────────────────────────────────────
    (format stream "# ============================================================~%")
    (format stream "# PUNTO DE ENTRADA~%")
    (format stream "# ============================================================~%~%")
    (format stream "if __name__ == '__main__':~%")
    (format stream "    mostrar_modelo()~%~%")
    (format stream "    solucion, costo = algoritmo_genetico(~a)~%~%"
            (format nil "~{~a~^, ~}"
                    (append (list id-const) pool-consts otros-consts)))
    (format stream "    print()~%")
    (format stream "    mostrar_resultado(solucion)~%")))
