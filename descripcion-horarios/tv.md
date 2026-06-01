Horario TV 

- un programa tiene:
    - id
    - nombre 
    - tipo de progrma 
    - tipo de público
- un canal tiene:
    - id
    - nombre
    - días de transmisión
    - programas
- una hora:
    - id 
    - progrma
    - hora de inicio 
    - duración
    - hora de fin 

- la hora de fin es un cálculo automático a partir de la hora de inicio y la duración.
- la hora de inicio excepto en el primer programa es la hora de fin del programa anterior.
- necesitamos asignar programas a horas en dias de transmisión


Restricciones fuertes:
- No deben existir dos programas seguidos del mismo tipo.
