# EDSL-keyboard-macro

## Introducción
Este es el trabajo final de la materia "Analisis de Lenguajes de Programacion". El mismo consiste de un EDSL (lenguaje de dominio especifico embebido) para la definicion de macros de teclado, especialmente util para la automatización. El lenguaje sobre el que fue embebido es haskell. Este software nos permite crear código C, compilarlo (si gcc se encuentra instalado) y ejecutarlo.

### Stack
Este software utiliza [**Stack**](https://docs.haskellstack.org/).

Para poder ejecutar el programa primero hay que ejecutar:
```
stack setup
```
y luego compilar el proyecto con:
```
stack build
```

### ¿Cómo ejecutarlo?

Una vez compilado el proyecto, se puede correr el ejecutable definido en `app/Main.hs` sobre un archivo `.kb` haciendo:
```
stack exec EDSL-keyboard-macro-exe -- PATH_TO_SOURCE [-OPT]
```
Las opciones disponibles son:
* `-p`: Imprimir el programa de entrada.
* `-a`: Mostrar el AST del programa de entrada.
* `-l`: Utilizar Linux (X11) como SO.
* `-w`: Utilizar Windows como SO.
* `-c`: Generar código C.
* `-e`: Compilar a un ejecutable.
* `-r`: Correr el Macro.
* `-h`: Imprimir ayuda.

Por ejemplo, para imprimir el programa `mouse.kb` del directorio `test`, ejecutar:
```
stack exec EDSL-keyboard-macro-exe -- test/mouse.kb -p
```
Para generar el codigo C y su ejecutable:
```
stack exec EDSL-keyboard-macro-exe -- test/mouse.kb -c -e
```

Tener en cuenta que el codigo C se puede generar eligiendo la plataforma (con `-l` o `-w`) y no depende de en que sistema operativo estamos ejecutando el compilador. Esto no es asi con la generacion del ejecutable o la opcion de correr el macro, estas tienen como restriccion que el compilador este funcionando en el mismo SO para el que se lo esta tratando de compilar.
