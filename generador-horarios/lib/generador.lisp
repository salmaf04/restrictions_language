;; =====================================================================
;; generador.lisp — Punto de entrada del generador de código Python
;; =====================================================================
;; Depende únicamente de: ast/clases-macros.lisp
;;
;; Carga tu dominio ANTES de este archivo y luego llama:
;;
;;   (generar-python "salida.py"
;;     :entidad-horario       'asignacion
;;     :consultas             '(conflictos-de-horario dias-asistidos)
;;     :restricciones-duras   '(restriccion-sin-conflictos-de-horario)
;;     :restricciones-blandas '(restriccion-minimizar-carga-maxima))
;;
;; Módulos que componen el generador:
;;   gen-utils          — py-nombre, py-indent, flatten-op, math-nombre
;;   gen-ast-python     — *reg-consultas*, bin->py, expr->py
;;   gen-ast-math       — *consultas-por-nombre*, bin->math, expr->math, ...
;;   gen-serializar     — instancia->py, emitir-lista-py, ...
;;   gen-consultas      — recolectar-dominios, generar-funcion-consulta
;;   gen-restricciones  — tipo-restriccion, generar-funcion-restriccion, ...
;;   gen-visualizacion  — generar-mostrar-modelo, generar-mostrar-resultado
;;   gen-metaheuristica — generar-algoritmo-genetico
;;
;; Tipos de cuantificador:
;;   nppq / tqpq  → restricciones simples  (duras,  PESO_DURA)
;;   tdpq / sbqp  → restricciones débiles  (blandas, PESO_BLANDA)
;;   minimizar / maximizar → objetivos de optimización (blandas)
;; =====================================================================

(load (merge-pathnames "lib/gen-utils.lisp"         (truename ".")))
(load (merge-pathnames "lib/gen-ast-python.lisp"    (truename ".")))
(load (merge-pathnames "lib/gen-ast-math.lisp"      (truename ".")))
(load (merge-pathnames "lib/gen-serializar.lisp"    (truename ".")))
(load (merge-pathnames "lib/gen-consultas.lisp"     (truename ".")))
(load (merge-pathnames "lib/gen-restricciones.lisp" (truename ".")))
(load (merge-pathnames "lib/gen-visualizacion.lisp" (truename ".")))
(load (merge-pathnames "lib/gen-metaheuristica.lisp" (truename ".")))


;; =====================================================================
;; PUNTO DE ENTRADA PRINCIPAL
;; =====================================================================

(defun generar-python (archivo-salida
                       &key entidad-horario
                            slot-identidad
                            slots-variables
                            consultas
                            restricciones-duras
                            restricciones-blandas
                            (peso-dura   1000)
                            (peso-blanda    1))
  "Genera un archivo Python completo a partir del AST.

   :entidad-horario       — símbolo de la entidad combinación (p. ej. 'asignacion)
   :slot-identidad        — slot fijo que identifica cada elemento (p. ej. 'tribunal)
   :slots-variables       — slots a asignar por el GA   (p. ej. '(fecha momento local))
   :consultas             — lista de símbolos defvar con consulta-simple
   :restricciones-duras   — lista de símbolos defvar con nppq/tqpq
   :restricciones-blandas — lista de símbolos defvar con tdpq/sbqp/minimizar/maximizar
   :peso-dura             — peso en la función objetivo (default 1000)
   :peso-blanda           — peso en la función objetivo (default 1)"

  ;; Registrar todas las consultas antes de generar expresiones
  (clrhash *reg-consultas*)
  (clrhash *consultas-por-nombre*)
  (dolist (nombre consultas)
    (when (boundp nombre)
      (registrar-consulta nombre (symbol-value nombre))
      (setf (gethash (py-nombre nombre) *consultas-por-nombre*)
            (symbol-value nombre))))

  (with-open-file (out archivo-salida
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)

    ;; ── Cabecera ───────────────────────────────────────────────────────
    (format out "# -*- coding: utf-8 -*-~%")
    (format out "# Generado automaticamente desde el AST~%~%")
    (format out "import sys, copy, random~%")
    (format out "from dataclasses import dataclass, field~%")
    (format out "from typing import List~%~%")
    (format out "# Forzar UTF-8 para poder mostrar simbolos matematicos~%")
    (format out "if hasattr(sys.stdout, 'reconfigure'):~%")
    (format out "    sys.stdout.reconfigure(encoding='utf-8')~%~%~%")

    ;; ── Entidades del dominio ──────────────────────────────────────────
    (format out "# ============================================================~%")
    (format out "# ENTIDADES DEL DOMINIO~%")
    (format out "# ============================================================~%~%")

    ;; unsafe_hash=True permite usar instancias de entidad en sets (p.ej. dias distintos)
    (maphash (lambda (nombre slots)
               (if (eq nombre entidad-horario)
                   (format out "@dataclass~%")
                   (format out "@dataclass(unsafe_hash=True)~%"))
               (format out "class ~a:~%" (string-capitalize (py-nombre nombre)))
               (if slots
                   (dolist (s slots)
                     (format out "    ~a: object = None~%" (py-nombre s)))
                   (format out "    pass~%"))
               ;; __str__ para impresión legible
               (unless (eq nombre entidad-horario)
                 (generar-str-entidad slots out))
               (format out "~%"))
             *slots-de-entidad*)

    ;; ── Clase Horario ──────────────────────────────────────────────────
    ;; Incluye un campo por cada tipo de entidad usada como dominio en las
    ;; consultas, más la entidad principal.
    (let ((dominios (recolectar-dominios consultas)))
      (pushnew entidad-horario dominios)
      (format out "@dataclass~%")
      (format out "class Horario:~%")
      (dolist (ent dominios)
        (format out "    ~a: List = field(default_factory=list)~%"
                (py-nombre ent)))
      (format out "~%~%~%"))

    ;; ── Consultas ──────────────────────────────────────────────────────
    (format out "# ============================================================~%")
    (format out "# CONSULTAS~%")
    (format out "# ============================================================~%~%")

    (dolist (nombre consultas)
      (when (boundp nombre)
        (generar-funcion-consulta nombre (symbol-value nombre) out)))

    ;; ── Restricciones simples / duras ──────────────────────────────────
    (format out "# ============================================================~%")
    (format out "# RESTRICCIONES SIMPLES / DURAS  (nppq / tqpq)~%")
    (format out "# Cada función devuelve el numero de veces que se incumple.~%")
    (format out "# ============================================================~%~%")

    (dolist (nombre restricciones-duras)
      (when (boundp nombre)
        (generar-funcion-restriccion nombre (symbol-value nombre) out)))

    ;; ── Restricciones débiles / blandas ───────────────────────────────
    (format out "# ============================================================~%")
    (format out "# RESTRICCIONES DEBILES / BLANDAS  (tdpq / sbqp)~%")
    (format out "# Cada función devuelve el numero de veces que se incumple.~%")
    (format out "# ============================================================~%~%")

    (dolist (nombre restricciones-blandas)
      (when (boundp nombre)
        (generar-funcion-restriccion nombre (symbol-value nombre) out)))

    ;; ── Modelo matemático ──────────────────────────────────────────────
    (format out "# ============================================================~%")
    (format out "# MODELO MATEMATICO~%")
    (format out "#   costo = PESO_DURA   * sum(violaciones duras)~%")
    (format out "#         + PESO_BLANDA * sum(violaciones blandas)~%")
    (format out "# ============================================================~%~%")

    (format out "PESO_DURA   = ~a~%" peso-dura)
    (format out "PESO_BLANDA = ~a~%~%" peso-blanda)

    (format out "def evaluar(horario):~%")
    (format out "    costo = 0~%")
    (when restricciones-duras
      (format out "    # restricciones simples / duras~%")
      (dolist (nombre restricciones-duras)
        (format out "    costo += PESO_DURA   * ~a(horario)~%" (py-nombre nombre))))
    (when restricciones-blandas
      (format out "    # restricciones debiles / blandas~%")
      (dolist (nombre restricciones-blandas)
        (format out "    costo += PESO_BLANDA * ~a(horario)~%" (py-nombre nombre))))
    (format out "    return costo~%~%~%")

    ;; Calcular nombres de constantes y pasar a los generadores
    (let* ((dominios-consultas (recolectar-dominios consultas))
           (otros-dominios (remove-if (lambda (d)
                                        (or (eq d entidad-horario)
                                            (eq d slot-identidad)))
                                      dominios-consultas))
           (id-const    (string-upcase (format nil "~as" (py-nombre slot-identidad))))
           (pool-consts (mapcar (lambda (v)
                                  (string-upcase (format nil "pool_~a" (py-nombre v))))
                                slots-variables))
           (otros-consts (mapcar (lambda (d) (string-upcase (py-nombre d)))
                                 otros-dominios))
           (id-py   (py-nombre slot-identidad))
           (vars-py (mapcar #'py-nombre slots-variables))
           (ent-py  (py-nombre entidad-horario)))

      ;; ── Visualización del modelo ──────────────────────────────────
      (generar-mostrar-modelo restricciones-duras restricciones-blandas
                              peso-dura peso-blanda
                              id-const pool-consts id-py vars-py otros-consts out)

      ;; ── Visualización del resultado ───────────────────────────────
      (generar-mostrar-resultado restricciones-duras restricciones-blandas
                                 peso-dura peso-blanda
                                 ent-py id-py vars-py out)

      ;; ── Algoritmo genético ────────────────────────────────────────
      (generar-algoritmo-genetico entidad-horario slot-identidad slots-variables
                                  otros-dominios
                                  id-const pool-consts otros-consts out)))

  (format t "~%Python generado en: ~a~%" archivo-salida))
