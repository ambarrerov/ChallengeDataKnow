<!-- ===================== -->
<!--        PORTADA        -->
<!-- ===================== -->

# 1. **Prueba Técnica – Ingeniería de Datos Dataknow**

![Logo DataKnow](.imgs/_dataknow/logo2020DataKnow.png)

> **Agradecimientos:** Muchas gracias a los evaluadores por dedicar tiempo a revisar este proyecto.

**Autor:** Andres Mauricio Barrero Velásquez  
**Correo:** andresvlasquez@gmail.com 
**Fecha:** 29/06/2026  
**Github de este repositorio** https://github.com/ambarrerov/ChallengeDataKnow
**Linkeln** www.linkedin.com/in/juan-camilo-barrero-velasquez-engineer

---
Tabla de contenido

Escenario FinBank
Motivación de la selección del escenario
Fase 1 – Generación de datos y modelo relacional
Generación de datos
Carga de datos a Azure SQL
Archivo de configuración
Modelo entidad-relación
Resultado del proceso de carga

---

# 2. Escenario Finbank

FinBank S.A. es un banco digital fundado en 2015 con presencia en cinco países de Latinoamérica: Colombia, Mexico, Peru, Chile y Argentina. Opera exclusivamente a través de canales digitales, aplicación móvil, portal web y una red de corresponsales bancarios, y cuenta con más de dos millones de clientes activos. Su cartera de crédito supera los USD 800 millones y el banco procesa en promedio 1.2 millones de transacciones diarias entre pagos, transferencias, recargas y avances. 
    
El modelo de negocio se basa en tres líneas de producto: crédito de consumo (créditos de libre inversión, crédito rotativo y tarjeta digital), cuentas de ahorro digitales y servicios transaccionales como pagos PSE, transferencias ACH y corresponsalía.
    
La base de clientes está segmentada internamente en cuatro categorías: Básico, Estándar, Premium y Elite. 
    
El equipo de Riesgo Crediticio monitorea diariamente el comportamiento de la cartera y calcula las provisiones regulatorias exigidas por la Superintendencia Financiera. Actualmente trabaja con reportes manuales en Excel construidos cada mañana durante aproximadamente dos horas a partir de múltiples fuentes desconectadas, lo que genera inconsistencias, retrasos y riesgo operativo.
    
Por otra parte, el área de Prevención de Fraude opera mediante reglas manuales que requieren ser enriquecidas con señales históricas del comportamiento del cliente. 
    
La necesidad principal consiste en desarrollar un pipeline que consolide toda esta información para que ambas áreas puedan consumir datos confiables y actualizados sin depender de procesos manuales.

## Motivacion de seleccion de escenarion y carga en base de datos relacional

De los cuatro sectores propuestos decidí trabajar el escenario de Banca y Servicios Financieros, ya que es un dominio que considero especialmente interesante y cuyos conceptos me resultan familiares. Además, me pareció el escenario más desafiante para demostrar habilidades relacionadas con Ingeniería de Datos.

Como motor de base de datos relacional elegí Azure SQL Database, debido a que me encuentro familiarizado con el ecosistema de Microsoft Azure y cuento con la certificación Microsoft Azure Fundamentals (AZ-900). Esto permitió desarrollar una arquitectura similar a la que podría encontrarse en un entorno empresarial. 

## FASE 1 — GENERACION DE DATOS Y MODELO RELACIONAL

Para la generacion de datos se tomo como guia las tablas que sugeria el escenario Finbank, no obstante se usaron script de generacion de mockup usando la libreria de `faker` de python. Importante aclarar que los script siguien las instrucciones de calidad de datos(distribucion normal de nullos etc) y que fueron generado con IA solo la generacion de estos datasets, sin embargo la logica de despliegue de los datos usando el controlador de `JDBC` en spark para poblaar tablas en una base de datos `sql server` en azure como fuente ficticia de datos para el desarrollo de todo este escenario.


<!-- ENTREGABLES FASE 1
• Script de generación de datos dummy con semilla aleatoria fija y parámetros
configurables
• Script SQL o Python de carga en la base de datos relacional seleccionada
• Diagrama Entidad-Relación (ER) de todas las tablas generadas, ubicado en la
carpeta /docs del repositorio
• Evidencia de la carga exitosa: captura de pantalla o resultado de SELECT
COUNT(*) por tabla -->


### Script de generacion de datos dummy

nota: el script de generacion esta dentro del notebook `datagen.pyibn`

Uno de los principales retos de esta prueba fue construir un conjunto de datos suficientemente representativo para desarrollar el resto del proyecto.

Debido a que modelar todos los posibles eventos de un negocio bancario requiere un conocimiento funcional amplio, se utilizó inteligencia artificial como apoyo para construir los generadores de datos sintéticos, los cuales posteriormente fueron ajustados para satisfacer las necesidades del proyecto.

Las siguientes funciones generan los seis conjuntos de datos utilizados durante toda la prueba:

```python
def generar_sucursales():
    ...

def generar_productos():
    ...

def generar_clientes():
    ...

def generar_obligaciones():
    ...

def generar_batch_movimientos():
    ...

def generar_comisiones():
    ...
```

### cargue de datos a base sql

Una vez generados los datos, estos fueron cargados hacia Azure SQL Database utilizando Apache Spark mediante el controlador `JDBC`.

Para evitar exponer credenciales dentro del código, la configuración de conexión fue externalizada mediante un archivo `config.json`, mientras que las credenciales fueron almacenadas como secretos en `Azure Key Vault`, permitiendo una administración más segura de la información sensible.

La función encargada de realizar el proceso de escritura es la siguiente:

```python

def write_jdbc(df_spark, table, mode="overwrite"):
    full = f"{SCHEMA_SQL}.{table}"
    cnt  = df_spark.count()
    print(f"  ⏳ {full} — {cnt:,} registros ...")
    (df_spark.write.format("jdbc")
        .option("url",      JDBC_URL)
        .option("dbtable",  full)
        .option("user",     JDBC_PROPS["user"])
        .option("password", JDBC_PROPS["password"])
        .option("driver",   JDBC_PROPS["driver"])
        .option("batchsize", 10_000)
        .option("numPartitions", 8)
        .mode(mode)
        .save())
    print(f"  ✅ {full} cargada")

```

#### configuracion de el script de geneacion de datos:

Todos los parámetros relacionados con la generación de datos y la conexión a la base de datos fueron centralizados en el archivo con ruta `/config/config.json`

Este archivo permite modificar el comportamiento del proceso sin necesidad de alterar el código fuente e incluye:

    -configuración del Azure Key Vault;
    -nombres de los secretos utilizados para la conexión;
    -cantidad de registros por tabla;
    -países simulados;
    -porcentaje de valores nulos;
    -semilla aleatoria;
    -esquema de la base de datos;
    -parámetros para la generación de anomalías.

```json
    {
    "key_vault": {
        "scope": "finbank-kv-scope",
        "keys": {
        "host":     "finbank-sql-host",
        "port":     "finbank-sql-port",
        "db":       "finbank-sql-db",
        "user":     "finbank-sql-user",
        "password": "finbank-sql-password"
        }
    },
    "data_config": {
        "TB_CLIENTES_CORE":   10000,
        "TB_PRODUCTOS_CAT":      50,
        "TB_MOV_FINANCIEROS": 500000,
        "TB_OBLIGACIONES":     30000,
        "TB_SUCURSALES_RED":     200,
        "TB_COMISIONES_LOG":   80000,
        "historico_meses":        12,
        "paises":   ["Colombia", "Mexico", "Peru", "Chile", "Argentina"],
        "null_rate":            0.05,
        "random_seed":            42,
        "schema":              "dbo",
        "anomalias": {
        "duplicados_mov":        500,
        "fechas_fuera_rango":    200,
        "montos_inconsistentes": 150
        }
    }
    }
```

### Representacion grafica ER de las tablas generadas

![Modelo ER](.imgs/_fase_1/ER_FINBANK.png)

El modelo implementado sigue una arquitectura similar a un esquema en estrella, conformado por tres tablas de dimensiones y tres tablas de hechos.

Las tablas de dimensiones:

`TB_CLIENTES_CORE`  
`TB_PRODUCTOS_CAT`  
`TB_SUCURSALES_RED`  

representan la información maestra del negocio, siendo el cliente la entidad central del modelo.

Las tablas de hechos registran los principales eventos operacionales del banco:

`TB_OBLIGACIONES` almacena la cartera de créditos, relacionando clientes y productos.
`TB_MOV_FINANCIEROS` constituye la tabla de mayor volumen (500.000 registros), registrando cada transacción realizada y relacionándola con el cliente, el producto y la sucursal donde fue originada.
`TB_COMISIONES_LOG` registra las comisiones generadas por las transacciones financieras, relacionando cada comisión con el cliente y con el movimiento que la originó.

nota: para más detalle: data-generation/README.md

### Demostracion de la ejecucion de cargue de datos:

![Tablas](.imgs/_fase_1/SS-tablas.png)

```bash
=======================================================
📋 VALIDACIÓN FINAL — [REDACTED] Mockup
=======================================================
  ✅ TB_SUCURSALES_RED                200 registros
  ✅ TB_PRODUCTOS_CAT                  50 registros
  ✅ TB_CLIENTES_CORE              10,000 registros
  ✅ TB_OBLIGACIONES               30,000 registros
  ✅ TB_MOV_FINANCIEROS           500,500 registros
  ✅ TB_COMISIONES_LOG             80,000 registros
  ──────────────────────────────────────────────────
  TOTAL                        620,750 registros
=======================================================
```

    nota: Tomado de el output de `validar_tabla()`

Con esta primera fase se obtuvo una fuente de datos relacional completamente funcional, desplegada sobre Azure SQL Database, que servirá como base para las siguientes etapas del proyecto: procesamiento, calidad de datos, modelado analítico y explotación de la información mediante Apache Spark.

