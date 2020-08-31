# Queries Kibana para ElasticSearch

## Resumen de filtros para usar en Kibana

1.  Filtros por texto

Podemos hacer filtros por texto con las siguientes entradas. 

* No Case Sensitive: esto indica si colocamos `Category` <> `category`.
* Con doble comilla busca la palabra de forma literal `"category\/health"` <> `category\/health`.
* Wildcard: `*` todos los carateres en un string y `?` todos los caracteres en el string.

```text
category
Category
categ
cat*
categ?ry
“category”
category\/health
“category/health”
Chrome
chorm*
```

2. Busquedas por campos

En este apartado vamos abuscar información por campo en particular. La sintaxis es:

```
<fieldname>:search
```

* *Busqueda por tipo de dato:* Las busquedas dependen del tipo de datos y distinguen entre mayusculas y minusculas a diferencia de la busqueda de tipo texto.
* *Busqueda por rango:* Se puede buscar por rangos si utilizamos `[]` es inclusivo y si utilizamos por `{}` es exclusivo.
* *_exist_:field_name* : Busca todos los documentos que existan en ese campo.
* *Rangos:* para poder usar rangos utilizamos la palabra `TO`.

```
name:chrome
name:Chrome
name:Chr*
response:200
bytes:65
bytes:[65 TO *]
bytes:[65 TO 99]
bytes:{65 TO 99}
_exists_:name
```

3. Declaraciones lógicas

Podemos utilizar concatenadores lógicos para poder hacer las consultas con AND y OR

* AND
* OR
* NOT, -, ! son los tres negación
* (), se pueden usar parentesis

```bash
kubernetes.pod_name:"logtofile-3-ggp2m" AND kubernetes.namespace_name:"developer-sidecar"
```