# Aprende a usar Google Gemini REST API desde Odin a través de `curl`

## Objetivos del artículo

- Aprender a usar `curl` en Odin (bindings a `libcurl` de C)
- Aprender a hacer llamadas la REST API de Google Gemini LLM

Nuestro programa hará lo equivalente al siguiente ejemplo de llamada de `curl` en la terminal:

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent" \
  -H "x-goog-api-key: real-api-key-here" \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Explica que es Odin Lang en 20 palabras"
          }
        ]
      }
    ]
  }'
```

> Se require una API KEY de Google Gemini para poder realizar solicitudes a la API

👀 Para obtener una API KEY de Google Gemini: https://ai.google.dev/gemini-api/docs/api-key?hl=es-419

Empezamos como siempre creando un proyecto de Odin con un `main.odin` y poniendo los elementos básicos de `package` y el procedure `main`, que siempre se necesita. Recuerda que solo puede haber un procedure llamado así. Es importante recordar que en Odin hablamos de **procedimientos** en vez de **funciones**, como en otros lenguajes, pero son efectivamente lo mismo.

```odin
package main

main :: proc(){
	// código aquí...
}
```

Vamos a importar ahora las **librerías** internas que necesitamos para este pequeño programa:

```odin
package main

import "core:fmt"
import "core:os"
import "core:strings"
import "vendor:curl"

main :: proc(){
	// código aquí...
}
```

Necesitamos `fmt` para imprimir texto en pantalla. El `os` nos permitirá recibir input desde la terminal con `stdin` cuando el usuario inserte su propio _prompt_ para el LLM. `strings` nos permitirá trabajar con las strings del programa y tendremos que convertir en `cstring` los elementos de texto que tengamos, ya que `curl` que está basado en `libcurl` es una librería de C, con lo cual los strings debe ser _null terminated_, que no es el por defecto en Odin. Además, `strings` nos permitirá limpiar y dar formato a nuestros elementos de texto. Y por último, obviamente, tenemos que traer `curl` para poder hacer todas esas operaciones HTTP.

IMPORTANTE notar cómo `fmt`, `os` y `strings` viene de `core`, mientras que `curl` viene de `vendor`.

**¿Cuál va a ser la estructura general de nuestro programa? **

- El programa recibirá un INPUT del usuario que va a ser el prompt para el LLM.
- Necesitamos asignar un espacio de memoria en donde colocar los datos que recibimos como INPUT del usuario.
- Para ello podemos crear un _buffer_ de 256 bytes, por ejemplo, pero puede ser del tamaño que se desee.
  - El _buffer_ lo crearemos como un _array_ de elementos de tipo `u8` (unsigned integer de 8 bits)
- El input lo recibiremos usando `os` para acceder al `stdin` (entrada estándar)
- Vamos a crear un elemento con formato _json_ como los que se suelen pasar en el espacio `-d` (data) de llamadas `curl` en la terminal (ver ejemplo de llamada `curl` en terminal)
- Vamos a crear elementos `headers` usando una _linked list_ de strings en `curl` a la que se pueden ir añadiendo otros elementos. Es una manera de ir conformando pedazo a pedazo todo el texto de `curl`
- Luego, instanciaremos un _handle_ de `curl`, que es un objeto que guarda el estado de una petición determinada. Esta última lleva la URL, los headers, el método (en nuestro caso es POST), el _callback_ de respuesta (el procedimiento que se ejecuta sobre la respuesta recibida) y el cuerpo del request (la petición). El _handle_ sirve para configurar y ejecutar la transferencia.
- Vamos a pasarle opciones de lo que queremos a nuestro _handle_
- Escribiremos un procedimiento para usar como `callback` para, en nuestro caso, imprimir en pantalla la respuesta recibida.
- Ejecutaremos el request y manejaremos la respuesta, y la imprimiremos en la terminal, como `stdout`.

**IMPORTANTE**: En Odin hacemos manejo manual de memoria. Esto significa que asignamos memoria para los objetos de nuestro programa y luego **liberamos** esa memoria para que pueda ser usada en otros procesos. Esto es sumamente importante en programación a bajo nivel. Veremos como usar procedimientos de _free_ en el caso de `curl` .

Empezamos con la definición de una constante `GEMINI MODEL` con el modelo que querramos utilizar luego:

```odin
package main

import "core:fmt"
import "core:os"
import "core:strings"
import "vendor:curl"

// CONSTANTE ⬇️
GEMINI_MODEL :: "gemini-3.1-flash-lite-preview"

main :: proc(){
	// ...
}
```

Y ahora vamos con el desarrollo de nuestro procedimiento principal:

Lo primero que vamos a hacer es cargar la API KEY que necesitamos pasar luego en nuestro _request_ para poder hablar con el Gemini LLM. Para ello, debemos tener nueva API KEY que debemos exportar en nuestro entorno, donde ejecutemos el programa, para que la llave pueda ser correctamente cargada en nuestro código. Por ejemplo, haciendo esto en la terminal, en la sesión en la que ejecutaremos nuestro programa: `export GEMINI_API_KEY=the-real-api-key-aquí` y luego `odin run .` o ejecutar directamente el binario compilado `./builds/main`.

```odin
load_gemini_api_key_env :: proc() -> string {
	val, found := os.lookup_env("GEMINI_API_KEY", context.allocator)
	if !found {
		panic("GEMINI KEY NOT FOUND")
	}
	return val
}
```

Nótese cómo usamos aquí `os.lookup_env()` y le pasamos el nombre de la variable que queremos cargar desde el entorno y el asignador de memoria del contexto en donde lo pondremos (_context.allocator_). Y si no encontramos esta llave, hacemos un _panic()_ para detener nuestro programa, que sin este elemento, no funcionará.

Una vez tenemos este procedimiento, que puede estar en nuestro módulo principal (_main.odin_) o en otro (por ejemplo, _utils.odin_, siempre poniendo primero `package main`, para que formen parte del mismo espacio, package) podemos pasar a llamarlo y guardar el resultado en nuestra variable `GEMINI_API_KEY`:

```odin
main :: proc(){
	GEMINI_API_KEY := load_gemini_api_key_env()

}
```

Ahora vamos a crear un _buffer_ en donde guardaremos el INPUT prompt que nos pase el usuario.

```odin
fmt.println("PROMPT >>> ")

prompt_buffer: [256]u8 // 👈 array
```

Vemos cómo se crea un _array_ fijo (fix array, no varía su tamaño) de 256 elementos de tipo `u8` en este caso. Nótese que si se deseara poder pasar prompts más largo, habría que dotar al buffer de mucha más memoria, según fuera necesario.

Y luego, usamos `os.read` para leer desde `os.stdin`, o sea, para recibir lo que venga de la entrada estándar, y eso lo guardamos en el _buffer_ anteriormente creado para ello. 👀 **OJO**: nótese cómo usamos un _slice_ que es una vista flexible directa de nuestro _array_, o sea, es referenciar directamente la zona de memoria donde literalmente reside nuestro _buffer_.

Nos damos cuenta de que `os.read()` devuelve dos elementos: a) el número de bytes leídos, de tipo int, y b) un error, si se produce. Esto nos permite manejar la situación en la se produzca un error. Vemos aquí que chequeamos si el valor de `r_err` es diferente de `os.ERROR_NONE` y procedemos a lidiar con ello.

```odin
n, r_err := os.read(os.stdin, prompt_buffer[:])
if r_err != os.ERROR_NONE {
	fmt.println("ERROR LEYENDO INPUT:", r_err)
	return
}
```

Una vez hemos leído desde `stdin` lo que nos haya pasado el usuario, entonces convertimos esos bytes `u8` en un `string` propiamente, y lo limpiamos con el fin quitar espacios no deseamos. Nótese como usamos `strings` para ello.

```odin
input := string(prompt_buffer[:n])   // 👈 leemos la cantidad de bytes recibidos y
                                     // lo hacemos un string
input = strings.trim_space(input)    // 👈 quitamos los espacios extra
```

Luego, creamos el elemento de `-d` data, que sería un objeto json. Tenemos que seguir el esquema que requiere GEMINI API REST para ello, en el cual pasamos una llave `"contents"` que tiene como valor un array `[ ]` que lleva por dentro una llave `"parts"` que a su vez tiene como valor otro array con una llave `"text"` en donde ponemos el input prompt del usuario.

Aquí es importante notar lo siguiente en cuanto a formato de strings en Odin:

- usaremos `fmt.ctprintf()`
  - `c` porque se trata de strings de C
  - `t` porque se trata de un _temporary_ string (asignación de memoria temporal)
  - `printf` para hacer string con formato
- y usaremos `%q` para denotar que el elemento incluído es una _quote_, que implica que llevará _" "_ comillas, o sea que no se eliminarán.

```odin
// ----------------------------------------------------------------------------------
// 🔽 nótese cómo se escapan '\' las comillas

json_data := fmt.ctprintf("{{\"contents\":[{{\"parts\":[{{\"text\":%q}}]}}]}}", input)
// ----------------------------------------------------------------------------------
```

Hacemos lo mismo con el API KEY header:

```odin
api_key_header := fmt.ctprintf("x-goog-api-key: %s", GEMINI_API_KEY)
```

Y luego comenzamos a crear una lista enlazada (_linked list_) de _headers_ en `curl`. Vamos a usar `curl.slist_append()` para crear la lista y añadimos `nil` primeramente solo para crearla. Luego, ya creada, la referimos para seguir añadiendo elementos de texto e ir conformando los headers.

```odin
// ----------------------------------------------------------------------------------
// 🔽 Nótese el `defer`

headers := curl.slist_append(nil, cstring("Content-Type: application/json"))
headers = curl.slist_append(headers, api_key_header)
defer curl.slist_free_all(headers)
```

Habréis notado el `defer`. Este procedimiento nos permite diferir hasta la salida del bloque actual `main()` la liberación total de la memoria ocupada por el elemento _headers_ hasta ese momento. Siempre que asignamos memoria, debemos liberarla cuando ya no la necesitemos. `defer` nos libera de la necesidad recordar colocar el _free_ cuando querramos liberar esa memoria, y nos garantiza que será liberada al final el actual bloque siempre.

Ahora ya estamos en posición de crear un objeto _handle_ para manejar la sesión de `curl` que estamos creando. Para ello vamos a usar el `curl.easy_init()`, o sea, una _inicialización fácil_ de nuestro objeto de `curl`.

```odin
// --- Init curl ---

handle := curl.easy_init()
if handle == nil do panic("curl INIT FAILED!")
defer curl.easy_cleanup(handle)
```

OJO: fijaros cómo chequeamos que `handle` se haya instanciado bien o si no lanzamos un `panic()` porque querríamos hacer un crash de nuestro programa si no tenemos `curl` funcionando. Y luego también usamos `defer` para liberar memoria.

Lo siguiente es empezar a crear opciones para nuestra transferencia. Para ello estaremos usando `curl.easy_setopt()` que es un procedimiento que recibe 3 argumentos: 1) un pointer (`^`, puntero) a un _struct_ CURL, que es nuestro `handle` en este caso, 2) la opción como tal que queramos y 3) argumentos variables al estilo C. Mira la firma del procedimiento aquí:

```odin
easy_setopt :: proc(curl: ^CURL, option: option, #c_vararg args: ..any) -> code ---
```

Ponemos la `url` que vamos a llamar, usando igualmente `fmt.tprintf()`, para incluir el `GEMINI_MODEL` determinado anteriormente y añadimos las opciones de HTTPHEADER, POST y los campos de post, nuestro `json_data`, POSTFIELDS:

```odin
url := fmt.tprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent",
		GEMINI_MODEL,
	)

curl.easy_setopt(handle, .URL, cstring(raw_data(url))) // NÓTESE: cstring
curl.easy_setopt(handle, .HTTPHEADER, headers)
curl.easy_setopt(handle, .POST, 1)
curl.easy_setopt(handle, .POSTFIELDS, json_data)
```

Se puede notar cómo tenemos que convertir nuestra `url` de tipo string normal de Odin en una string de tipo C, y lo hacemos a través de un _cast_ (conversión) `cstring()`, pero no directamente sobre `url` sino sobre `raw_data` que se encarga de sacar la dirección en memoria de los bytes de la string `url`.

Entonces, lo que queremos ahora es crear un objeto string, una cadena de texto, en la que podamos guardar el output que obtengamos como respuesta de nuestra petición con `curl` para luego mostrarlo en pantalla, o hacer lo que queramos.

Para ello vamos a usar el procedimiento `strings.builder_make()` que nos permite crear un acumulador de texto vacío y expandible, como si fuera una caja donde vamos metiendo poco a poco pedazos de texto con el que luego podremos trabajar como decidamos. Observa cómo usamos de nuevo `defer` para liberar esa memoria cuando toque. Nota el `strings.builder_destroy()` al que le pasamos la dirección del response buffer creado.

```odin
response_buffer := strings.builder_make()
defer strings.builder_destroy(&response_buffer)
```

Añadimos ahora dos opciones más a nuestro `handle` de `curl`, a) una para escribir los datos y b) otra para llamar la función de escritura deseada.

```odin
curl.easy_setopt(handle, .WRITEDATA, &response_buffer)
curl.easy_setopt(handle, .WRITEFUNCTION, write_callback)
```

Por lo tanto, como se ve, hay que escribir nuestro procedimiento de `write_callback`. Lo haremos, claramente, **fuera** de donde estamos ahora, el procedimiento principal `main()`

```odin
write_callback :: proc(ptr: rawptr, size, nmemb: uint, userdata: rawptr) -> uint {
	n := size * nmemb
	builder := cast(^strings.Builder)userdata
	chunk := strings.string_from_ptr(cast(^u8)ptr, int(n))
	strings.write_string(builder, chunk)
	return uint(n)
}
```

Este procedimiento es el _gancho_ (hook) que necesitamos para ejecutar cada vez que `curl`nos envía en trozo de respuesta, ya que no la envía toda de una sola, sino que hace _stream_ de la misma. La firma del procedimiento es tal porque así lo requiere `libcurl` : a) un raw pointer (equivalente a `void *`en C ) al bloque de bytes recibidos, b) `size` y `nmemb`, que juntos indican cuántos bytes llegaron y c) `userdata`que es nuestro extra en este caso, el _builder_ donde lo vamos guardando todo. Es la firma que `libcurl` espera para _callbacks_ en C.

En nuestro caso este procedimiento hace lo siguiente:

- convierte el bloque recibido en texto
- lo pega al builder
- devuelve cuántos bytes consumió

Es interesante notar como convertimos con `cast()` los raw pointers `ptr` y `userdata` a pointers de tipo `u8` (que es como `byte`) y `strings.Builder` respectivamente, para que apunten primero a bytes, que es lo que necesita `strings.string_from_ptr()` y luego al tipo de nuestro _Builder_.

Luego de todo podemos finalmente ejecutar como tal la petición y usamos `curl.easy_perform()`, pasándole el `handle` que hemos estado conformando.

```odin
err := curl.easy_perform(handle)
if err != .E_OK {                                        // <--- código de error de curl
	fmt.println("curl FAILED!:", err)
	return
}
```

Y luego, imprimimos en pantalla la respuesta recibida: usando el `strings.to_string()` con el contenido de nuestro _response buffer_

```odin
fmt.println(strings.to_string(response_buffer))
```

Y así queda nuestro programa entero:

```odin
package main

import "core:fmt"
import "core:os"
import "core:strings"
import "vendor:curl"

GEMINI_MODEL :: "gemini-3.1-flash-lite-preview"

main :: proc() {

	GEMINI_API_KEY := load_gemini_api_key_env()

	fmt.println("PROMPT >>> ")

	prompt_buffer: [256]u8

	n, r_err := os.read(os.stdin, prompt_buffer[:])
	if r_err != os.ERROR_NONE {
		fmt.println("ERROR LEYENDO INPUT:", r_err)
		return
	}

	input := string(prompt_buffer[:n])
	input = strings.trim_space(input)

	json_data := fmt.ctprintf("{{\"contents\":[{{\"parts\":[{{\"text\":%q}}]}}]}}", input)

	api_key_header := fmt.ctprintf("x-goog-api-key: %s", GEMINI_API_KEY)

	headers := curl.slist_append(nil, cstring("Content-Type: application/json"))
	headers = curl.slist_append(headers, api_key_header)
	defer curl.slist_free_all(headers)


	// --- Init curl ---
	handle := curl.easy_init()
	if handle == nil do panic("curl INIT FAILED!")
	defer curl.easy_cleanup(handle)
	// -----------------

	url := fmt.tprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent",
		GEMINI_MODEL,
	)                                               // Nótese el %s

	curl.easy_setopt(handle, .URL, cstring(raw_data(url)))
	curl.easy_setopt(handle, .HTTPHEADER, headers)
	curl.easy_setopt(handle, .POST, 1)
	curl.easy_setopt(handle, .POSTFIELDS, json_data)

	response_buffer := strings.builder_make()
	defer strings.builder_destroy(&response_buffer)

	curl.easy_setopt(handle, .WRITEDATA, &response_buffer)
	curl.easy_setopt(handle, .WRITEFUNCTION, write_callback)

	err := curl.easy_perform(handle)
	if err != .E_OK {
		fmt.println("curl FAILED!:", err)
		return
	}

	fmt.println(strings.to_string(response_buffer))

}

write_callback :: proc(ptr: rawptr, size, nmemb: uint, userdata: rawptr) -> uint {
	n := size * nmemb
	builder := cast(^strings.Builder)userdata
	chunk := strings.string_from_ptr(cast(^byte)ptr, int(n))
	strings.write_string(builder, chunk)
	return uint(n)
}

load_gemini_api_key_env :: proc() -> string {
	val, found := os.lookup_env("GEMINI_API_KEY", context.allocator)
	if !found {
		panic("GEMINI KEY NOT FOUND")
	}
	return val
}


```

### Resumen de **procs** y **structs** usados:

- `os`:
  - _os.read()_
    - `os.read(os.stdin, prompt_buffer[:])`
  - _os.ERROR_NONE_
  - _os.lookup_env()_
    - `os.lookup_env("GEMINI_API_KEY", context.allocator)`
- `strings`
  - _strings.trim_space()_
    - `strings.trim_space(input)`
  - _strings.builder_make()_
  - _strings.builder_destroy()_
  - _strings.to_string()_
  - _strings.string_from_ptr()_
    - `strings.string_from_ptr(cast(^byte)ptr, int(n))`
  - _strings.write_string()_
    - `strings.write_string(builder, chunk)`
- `curl`
  - _curl.slist_append()_
    - `curl.slist_append(nil, cstring("Content-Type: application/json"))`
  - _curl.slist_free_all()_
  - _curl.easy_init()_
  - _curl.easy_cleanup()_
  - _curl.easy_setopt()_
    - `curl.easy_setopt(handle, .URL, cstring(raw_data(url)))`
    - `.URL`
    - `.HTTPHEADER`
    - `.POST`
    - `.POSTFIELDS`
    - `.WRITEDATA`
    - `.WRITEFUNCTION`
  - _curl.easy_perform()_
