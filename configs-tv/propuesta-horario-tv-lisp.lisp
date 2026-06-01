;;Programas TV 

(defparameter *programas-canal-habana*
  '((:nombre "ÁNIMA" :tipo-programa "animacion" :tipo-publico "juvenil")
    (:nombre "ALGO ENTRE MANOS" :tipo-programa "cultural" :tipo-publico "adulto")
    (:nombre "CANAL HABANA DEPORTES" :tipo-programa "deporte" :tipo-publico "toda-la-familia")))

;;Programación

(defstruct emision-tv
  nombre
  hora-inicio
  duracion)

(defstruct dia-tv
  nombre-dia
  programas)

(defparameter *planificacion-lunes*
  (make-dia-tv 
   :nombre-dia 'lunes[cite: 3]
   :programas 
   (list 
    (make-emision-tv :nombre "EL TIEMPO Y LA MEMORIA" :hora-inicio "16:00" :duracion 5)
    (make-emision-tv :nombre "COORDENADAS" :hora-inicio "16:05" :duracion 5)
    (make-emision-tv :nombre "REVISTA HOLA HABANA" :hora-inicio "16:10" :duracion 50))))

