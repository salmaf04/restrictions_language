;; =====================================================================
;; BASE
;; =====================================================================

(defclass nodo-ast () ()
  (:documentation "Clase base absoluta para todos los nodos del árbol."))


;; =====================================================================
;; ENTIDADES
;; =====================================================================

(defclass entidad () ())

(defclass ref-gen-entidad ()
  ((nombre-entidad :initarg :nombre-entidad :reader nombre-entidad)))

(defclass ref-especifica-ent () ())


;; =====================================================================
;; MACROS
;; =====================================================================

;; Expande formatos compactos de slot a la forma canónica de defclass:
;;   (nombre accessor)          → (nombre :initarg :nombre   :accessor accessor)
;;   (nombre :initarg-kw acc)   → (nombre :initarg :initarg-kw :accessor acc)
;;   forma canónica             → se deja pasar tal cual
(defun %expand-slot (slot)
  (cond ((= (length slot) 2)
         `(,(first slot) :initarg ,(intern (symbol-name (first slot)) :keyword)
                          :accessor ,(second slot)))
        ((= (length slot) 3)
         `(,(first slot) :initarg ,(second slot) :accessor ,(third slot)))
        (t slot)))


;; Genera (defclass NOMBRE PADRES SLOTS), el constructor (defun def-NOMBRE PARAMS ...)
;; y una función de acceso AST por cada slot: (defun INITARG (entidad) ...).
;;
;; Slots pueden escribirse en formato compacto:
;;   (nombre accessor)         → initarg derivado del nombre del slot
;;   (nombre :initarg-kw acc)  → initarg explícito (cuando difiere del nombre)
;;
;; Params-extra opcionales:
;;   :key            → constructor con &key (params derivados de los slots)
;;   :variadic p1 p2 → constructor variádico que encadena N args por reducción
;;   p1 p2           → constructor posicional con params explícitos
;;   (vacío y sin slots) → solo defclass, sin constructor ni accesores
(defmacro def-clase (nombre padres slots &rest params-extra)
  (let* ((nombre-str  (symbol-name nombre))
         (fn-sym      (intern (concatenate 'string "DEF-" nombre-str)))
         (keyword-p   (equal params-extra '(:key)))
         (variadic-p  (eq (first params-extra) :variadic))
         (real-extra  (if variadic-p (rest params-extra) params-extra))
         (slots-full  (mapcar #'%expand-slot slots))
         (derivados   (mapcar (lambda (slot)
                                (intern (symbol-name (getf (cdr slot) :initarg))))
                              slots-full))
         (params      (cond (keyword-p  derivados)
                            (variadic-p real-extra)
                            (real-extra real-extra)
                            (t          derivados)))
         (initargs    (loop for p in params
                            unless (member p lambda-list-keywords)
                            append (list (intern (symbol-name p) :keyword) p)))
         (lambda-ll   (if keyword-p (cons '&key params) params))
         (acc-fns     (mapcar (lambda (slot)
                                (let ((acc (intern (symbol-name (getf (cdr slot) :initarg)))))
                                  `(defun ,acc (entidad)
                                     (def-acceso-a-atributo-de-entidad entidad ',acc))))
                              slots-full))
         ;; Para :variadic: los params se mapean a (a b) en el lambda del reduce
         (var-initargs (when variadic-p
                         (loop for p in params
                               for lp in '(a b)
                               append (list (intern (symbol-name p) :keyword) lp)))))
    `(progn
       (defclass ,nombre ,padres ,slots-full)
       ,@(cond
           (variadic-p
            `((defun ,fn-sym (&rest args)
                (reduce (lambda (a b) (make-instance ',nombre ,@var-initargs)) args))))
           (params
            `((defun ,fn-sym ,lambda-ll
                (make-instance ',nombre ,@initargs)))))
       ,@acc-fns)))


;; Define en una sola forma múltiples clases que heredan de nodo-ast.
;; Cada spec tiene la forma (NOMBRE SLOTS &rest PARAMS-EXTRA), que expande a
;; (def-clase NOMBRE (nodo-ast) SLOTS PARAMS-EXTRA...).
(defmacro def-nodos (&rest specs)
  `(progn
     ,@(mapcar (lambda (spec)
                 `(def-clase ,(first spec) (nodo-ast) ,@(rest spec)))
               specs)))


;; Define en una sola forma múltiples grupos de subclases.
;; Cada spec tiene la forma (PADRE (PARAMS...) nombre1 nombre2 ...).
(defmacro def-jerarquias (&rest grupos)
  `(progn
     ,@(mapcar (lambda (grupo)
                 `(def-subclases ,(first grupo) ,(second grupo) ,@(cddr grupo)))
               grupos)))


;; Define en una sola forma un grupo de subclases que comparten el mismo padre
;; y el mismo constructor. Expande a (def-clase NOMBRE (PADRE) () PARAMS...) por cada nombre.
(defmacro def-subclases (padre params &rest nombres)
  `(progn
     ,@(mapcar (lambda (nombre)
                 `(def-clase ,nombre (,padre) () ,@params))
               nombres)))


;; =====================================================================
;; NODOS DEL AST
;; =====================================================================

(def-nodos
  ;; Estructuras de datos
  (comb-entidades     ((entidades comb-entidades-lista)))
  (lista              ((elementos lista-elementos)))
  ;; Acceso a datos
  (acceso-a-atributo-de-entidad ((atributo acceso-atributo)
                                  (entidad  acceso-entidad)))
  (acceso-a-elemento-de-comb    ((entidad        acceso-comb-entidad)
                                  (comb-entidades acceso-comb-origen)))
  ;; Consulta
  (consulta-simple
    ((args               consulta-args)
     (variable-iteracion consulta-var-iter)
     (dominio-iteracion  consulta-dominio)
     (comprobacion       consulta-comprobacion)
     (operacion          consulta-operacion)
     (retorno            consulta-retorno))
    :key)
  ;; Cuantificadores (padre de nppq, tqpq, tdpq, sbqp)
  (cuantificador-restriccion ((operador     cuanti-operador)
                               (comprobacion cuanti-comprobacion)
                               (elemento     cuanti-elemento)))
  ;; Comprobaciones de conjuntos
  (hay-elementos-duplicados ((lista     check-duplicados-lista)))
  (pertenece                ((elemento  pertenece-elemento)
                             (coleccion pertenece-coleccion)))
  ;; Operaciones — initarg difiere del nombre del slot, se especifica explícito
  (operacion-binaria ((operando-izq :izq op-izq)
                      (operando-der :der op-der)))
  (operacion-unaria  ((operando op-operando))))

(def-jerarquias
  ;; Categorías semánticas
  (operacion-binaria (izq der)
    operacion-aritmetica comprobacion-aritmetica operacion-logica-binaria)
  (operacion-unaria (operando)
    operacion-logica-unaria)
  ;; Cuantificadores
  (cuantificador-restriccion (comprobacion &optional elemento)
    nppq tqpq tdpq sbqp)
  ;; Lógicas — op-and y op-or son variádicos (encadenan N args por reducción)
  (operacion-logica-binaria (:variadic izq der) op-and op-or)
  (operacion-logica-unaria  (operando) op-not)
  ;; Relacionales
  (comprobacion-aritmetica (izq der)
    op-igual op-distinto op-mayor op-menor op-mayor-igual op-menor-igual)
  ;; Aritméticas
  (operacion-aritmetica (izq der)
    op-suma op-resta op-multiplicacion op-division))


;; =====================================================================
;; DSL — MACROS DE DOMINIO
;; =====================================================================

;; Registro de slots por entidad, necesario para que def-entidad herede
;; los slots de los mixins al construir el constructor de instancias.
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *slots-de-entidad* (make-hash-table)))


;; Define una clase mixin con slots simples.
;; def-clase genera automáticamente el constructor y las funciones de acceso AST.
;;
;; (defclass* tiene-nombre () (nombre))
;; → (nombre ent) construye un nodo de acceso AST
(defmacro defclass* (nombre padres slots)
  `(progn
     (eval-when (:compile-toplevel :load-toplevel :execute)
       (setf (gethash ',nombre *slots-de-entidad*) ',slots))
     (def-clase ,nombre ,padres
       ,(mapcar (lambda (s) `(,s ,s)) slots))))


;; Define una entidad de dominio con padres opcionales (mixins) y slots propios.
;; Genera vía def-clase: clase específica con herencia, clase genérica, defvar,
;; funciones de acceso AST y macro constructor DEF-NOMBRE.
;;
;; (def-entidad profesor (tiene-nombre) (grado))
;; (def-profesor piad "Alejandro Piad" grado-dr)   ← orden: slots mixin, slots propios
(defmacro def-entidad (nombre padres &optional (slots '()))
  (let* ((str         (symbol-name nombre))
         (ref-gen-sym (intern (concatenate 'string "REF-GEN-A-" str)))
         (ref-esp-sym (intern (concatenate 'string "REF-ESPECIFICA-A-" str)))
         (mk-sym      (intern (concatenate 'string "DEF-" str)))
         (mixin-slots (loop for p in padres
                            append (gethash p *slots-de-entidad* '())))
         (all-slots   (append mixin-slots slots))
         (slot-defs   (mapcar (lambda (s) `(,s ,s)) slots)))
    `(progn
       (eval-when (:compile-toplevel :load-toplevel :execute)
         (setf (gethash ',nombre *slots-de-entidad*) ',all-slots))
       (def-clase ,ref-esp-sym (,@padres ref-especifica-ent) ,slot-defs)
       (defclass  ,ref-gen-sym (ref-gen-entidad) ())
       (defvar    ,nombre (make-instance ',ref-gen-sym :nombre-entidad ',nombre))
       (defmacro  ,mk-sym (inst-nombre &rest arg-values)
         (let* ((all-sl ',all-slots)
                (initargs (loop for s in all-sl
                                for v in arg-values
                                append (list (intern (symbol-name s) :keyword) v))))
           `(defvar ,inst-nombre
              (make-instance ',',ref-esp-sym ,@initargs)))))))


;; Entidad que agrupa otras entidades como componentes (sin padres mixin).
;;
;; (def-comb asignacion (tribunal fecha momento local))
(defmacro def-comb (nombre componentes)
  `(def-entidad ,nombre () ,componentes))


;; Define una consulta reutilizable (defun) o una consulta completa (defvar + consulta-simple).
;;
;; Sin :itera-sobre → función que recibe variables AST y devuelve un nodo condición.
;; Con :itera-sobre → defvar con nodo consulta-simple listo para evaluar.
(defmacro def-consulta (nombre params &key itera-sobre comprueba operacion devuelve)
  (if itera-sobre
      (let* ((iter-vars (mapcar #'first  itera-sobre))
             (iter-doms (mapcar #'second itera-sobre))
             (bindings  (mapcar (lambda (v) `(,v ',v)) iter-vars)))
        `(defvar ,nombre
           (let ,bindings
             (def-consulta-simple
               :args               ',params
               :variable-iteracion ',iter-vars
               :dominio-iteracion  (list ,@iter-doms)
               :comprobacion       ,comprueba
               :operacion          ',operacion
               :retorno            ',devuelve))))
      `(defun ,nombre ,params
         ,comprueba)))
