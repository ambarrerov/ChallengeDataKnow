# Catalogo de Datos — Proyecto DataKnow

**Entorno:** DEV  
**Ultima actualizacion:** 2026-06  
**Responsable:** Equipo de Datos  

---

## Estructura general

```
Bronze  →  Silver (cleaned / errors)  →  Gold (financiero)
```

---

## Capa Silver

### silver.cleaned.TB_CLIENTES_CORE
Informacion maestro de clientes. Cargue full mensual desde Bronze.

| Campo | Tipo | Descripcion |
|---|---|---|
| ID_CLIENTE | STRING | Identificador unico del cliente |
| NOMBRE_COMPLETO | STRING | Nombre completo — enmascarado con SHA-256 |
| TIPO_DOCUMENTO | STRING | Tipo de documento de identidad |
| NUMERO_DOCUMENTO | STRING | Numero de documento — enmascarado con SHA-256 |
| FECHA_NACIMIENTO | DATE | Fecha de nacimiento |
| EDAD | LONG | Edad calculada en años |
| FECHA_ALTA | DATE | Fecha de vinculacion del cliente |
| COD_SEGMENTO | STRING | Segmento comercial (MASIVO, PYME, PREFERENTE) |
| SCORE_BURO | LONG | Score de buro de credito |
| CIUDAD_RESIDENCIA | STRING | Ciudad de residencia |
| DEPARTAMENTO_RESIDENCIA | STRING | Departamento de residencia |
| PAIS_RESIDENCIA | STRING | Pais de residencia |
| ESTADO_CLIENTE | STRING | Estado del cliente (ACTIVO, INACTIVO) |
| CANAL_ADQUISICION | STRING | Canal por el que se vinculo el cliente |
| _FECHA_CARGA | DATE | Fecha de carga del registro |
| _FUENTE | STRING | Tabla de origen en Bronze |

---

### silver.cleaned.TB_PRODUCTOS_CAT
Catalogo de productos financieros. Cargue full mensual desde Bronze.

| Campo | Tipo | Descripcion |
|---|---|---|
| COD_PROD | STRING | Codigo unico del producto |
| DESC_PROD | STRING | Descripcion del producto |
| TIP_PROD | STRING | Tipo de producto |
| TASA_EA | DOUBLE | Tasa efectiva anual |
| PLAZO_MAX_MESES | LONG | Plazo maximo en meses |
| CUOTA_MIN | DOUBLE | Cuota minima |
| COMISION_ADMIN | DOUBLE | Comision administrativa |
| ESTADO_PROD | STRING | Estado del producto (ACTIVO, INACTIVO) |
| PERIODO | STRING | Periodo de carga MM-YYYY |
| _FECHA_CARGA | DATE | Fecha de carga del registro |
| _FUENTE | STRING | Tabla de origen en Bronze |

---

### silver.cleaned.TB_SUCURSALES_RED
Red de puntos de atencion. Cargue full mensual desde Bronze.

| Campo | Tipo | Descripcion |
|---|---|---|
| COD_CANAL | STRING | Codigo del canal |
| DESC_CANAL | STRING | Descripcion del canal |
| TIP_PUNTO | STRING | Tipo de punto de atencion |
| PERIODO | STRING | Periodo de carga MM-YYYY |
| _FECHA_CARGA | DATE | Fecha de carga del registro |
| _FUENTE | STRING | Tabla de origen en Bronze |

---

### silver.cleaned.TB_MOV_FINANCIEROS
Movimientos financieros de clientes. Cargue incremental mensual particionado por periodo.

| Campo | Tipo | Descripcion |
|---|---|---|
| ID_MOV | STRING | Identificador unico del movimiento |
| ID_CLI | STRING | Identificador del cliente |
| COD_PROD | STRING | Codigo del producto asociado |
| NUM_CUENTA | STRING | Numero de cuenta |
| FEC_MOV | DATE | Fecha del movimiento |
| HRA_MOV | STRING | Hora del movimiento (HH:mm:ss) |
| VR_MOV | DOUBLE | Valor del movimiento en COP |
| TIP_MOV | STRING | Tipo de movimiento (INTERES, COMISION, etc.) |
| COD_CANAL | STRING | Canal por el que se realizo el movimiento |
| COD_CIUDAD | STRING | Ciudad donde se realizo el movimiento |
| COD_ESTADO_MOV | STRING | Estado del movimiento (EXITOSO, FALLIDO) |
| ID_DISPOSITIVO | STRING | Identificador del dispositivo |
| IND_SOSPECHOSO | INT | 1 si el monto supera 3 desviaciones estandar del promedio movil de 30 dias del cliente |
| PERIODO | STRING | Particion MM-YYYY |
| _FECHA_EXTRACCION | DATE | Fecha de extraccion desde la fuente |
| _FUENTE | STRING | Tabla de origen en Bronze |

---

### silver.cleaned.TB_COMISIONES_LOG
Log de comisiones cobradas. Cargue incremental mensual particionado por periodo.

| Campo | Tipo | Descripcion |
|---|---|---|
| ID_COMISION | STRING | Identificador unico de la comision |
| ID_CLI | STRING | Identificador del cliente |
| COD_PROD | STRING | Codigo del producto asociado |
| FEC_COBRO | DATE | Fecha de cobro de la comision |
| VR_COMISION | DOUBLE | Valor de la comision en COP |
| TIP_COMISION | STRING | Tipo de comision |
| ESTADO_COBRO | STRING | Estado del cobro (COBRADO, PENDIENTE) |
| ID_MOV_REF | STRING | Referencia al movimiento asociado |
| PAIS | STRING | Pais donde se genero la comision |
| PERIODO | STRING | Particion MM-YYYY |
| _FECHA_EXTRACCION | DATE | Fecha de extraccion desde la fuente |
| _FUENTE | STRING | Tabla de origen en Bronze |

---

### silver.cleaned.TB_OBLIGACIONES
Obligaciones crediticias de clientes. Cargue incremental mensual particionado por periodo.

| Campo | Tipo | Descripcion |
|---|---|---|
| ID_OBLIG | STRING | Identificador unico de la obligacion |
| ID_CLI | STRING | Identificador del cliente |
| COD_PROD | STRING | Codigo del producto crediticio |
| VR_APROBADO | DOUBLE | Valor aprobado del credito |
| VR_DESEMBOLSADO | DOUBLE | Valor efectivamente desembolsado |
| SDO_CAPITAL | DOUBLE | Saldo de capital vigente |
| SDO_INTERES | DOUBLE | Saldo de intereses vigente |
| FEC_DESEMBOLSO | DATE | Fecha de desembolso |
| FEC_VENC | DATE | Fecha de vencimiento |
| DIAS_MORA_ACT | LONG | Dias de mora actuales |
| NUM_CUOTAS_PEND | LONG | Numero de cuotas pendientes |
| CALIF_RIESGO | STRING | Calificacion de riesgo de la fuente origen |
| CIUDAD | STRING | Ciudad de la obligacion |
| PAIS | STRING | Pais de la obligacion |
| PERIODO | STRING | Particion MM-YYYY |
| _FECHA_CARGA | DATE | Fecha de carga del registro |
| _FUENTE | STRING | Tabla de origen en Bronze |

---

## Capa Gold

### gold.financiero.dim_clientes
Dimension de clientes enriquecida para analisis.

| Campo | Tipo | Descripcion |
|---|---|---|
| ID_CLIENTE | STRING | Identificador unico del cliente (PK) |
| NOMBRE_COMPLETO | STRING | Nombre completo enmascarado |
| TIPO_DOCUMENTO | STRING | Tipo de documento |
| NUMERO_DOCUMENTO | STRING | Numero de documento enmascarado |
| FECHA_NACIMIENTO | DATE | Fecha de nacimiento |
| EDAD | LONG | Edad en años |
| FECHA_ALTA | DATE | Fecha de vinculacion |
| COD_SEGMENTO | STRING | Segmento comercial |
| SCORE_BURO | LONG | Score de buro |
| CIUDAD_RESIDENCIA | STRING | Ciudad de residencia |
| DEPARTAMENTO_RESIDENCIA | STRING | Departamento de residencia |
| PAIS_RESIDENCIA | STRING | Pais de residencia |
| ESTADO_CLIENTE | STRING | Estado del cliente |
| CANAL_ADQUISICION | STRING | Canal de adquisicion |
| _FECHA_CARGA | DATE | Fecha de carga |
| _FUENTE | STRING | Fuente de origen |

---

### gold.financiero.dim_productos
Dimension de productos con clasificacion de negocio y tasa mensual equivalente.

| Campo | Tipo | Descripcion |
|---|---|---|
| CODIGO_PRODUCTO | STRING | Codigo unico del producto (PK) |
| DESCRIPCION_PRODUCTO | STRING | Descripcion del producto |
| TIPO_PRODUCTO | STRING | Tipo de producto |
| TASA_EA | DOUBLE | Tasa efectiva anual |
| TASA_MENSUAL_EQUIVALENTE | DOUBLE | Tasa mensual equivalente calculada desde TEA |
| PLAZO_MAXIMO_MESES | LONG | Plazo maximo en meses |
| CUOTA_MINIMA | DOUBLE | Cuota minima |
| COMISION_ADMINISTRATIVA | DOUBLE | Comision administrativa |
| ESTADO_PRODUCTO | STRING | Estado del producto |
| FAMILIA_PRODUCTO | STRING | Familia: CREDITO / AHORRO / TRANSACCIONAL |
| _FECHA_CARGA | DATE | Fecha de carga |
| _FUENTE | STRING | Fuente de origen |

---

### gold.financiero.fact_transacciones
Hechos de movimientos financieros con montos en USD, flag de horario y deteccion de anomalias. Particionada por PERIODO.

| Campo | Tipo | Descripcion |
|---|---|---|
| ID_MOVIMIENTO | STRING | Identificador del movimiento |
| ID_CLIENTE | STRING | Identificador del cliente (FK dim_clientes) |
| CODIGO_PRODUCTO | STRING | Codigo del producto (FK dim_productos) |
| NUMERO_CUENTA | STRING | Numero de cuenta |
| FECHA_MOVIMIENTO | DATE | Fecha del movimiento |
| HORA_MOVIMIENTO | STRING | Hora del movimiento |
| MONTO_COP | DOUBLE | Monto en pesos colombianos |
| MONTO_USD | DOUBLE | Monto convertido a USD (TRM referencia) |
| TIPO_MOVIMIENTO | STRING | Tipo de movimiento |
| ESTADO_MOVIMIENTO | STRING | Estado del movimiento |
| CODIGO_CANAL | STRING | Canal de origen |
| CODIGO_CIUDAD | STRING | Ciudad del movimiento |
| FLAG_HORARIO | STRING | HABIL / NO HABIL segun dia y hora |
| PROMEDIO_MOVIL_30D | DOUBLE | Promedio movil de 30 dias por cliente |
| FLAG_ANOMALIA | INT | 1 si el monto supera 3 veces el promedio movil |
| PERIODO | STRING | Particion MM-YYYY |
| _FECHA_CARGA | DATE | Fecha de carga |
| _FUENTE | STRING | Fuente de origen |

---

### gold.financiero.fact_cartera
Hechos de obligaciones crediticias con clasificacion regulatoria y provision estimada. Particionada por PERIODO.

| Campo | Tipo | Descripcion |
|---|---|---|
| ID_OBLIGACION | STRING | Identificador de la obligacion |
| ID_CLIENTE | STRING | Identificador del cliente (FK dim_clientes) |
| CODIGO_PRODUCTO | STRING | Codigo del producto |
| CIUDAD | STRING | Ciudad de la obligacion |
| PAIS | STRING | Pais de la obligacion |
| VALOR_APROBADO | DOUBLE | Valor aprobado del credito |
| VALOR_DESEMBOLSADO | DOUBLE | Valor desembolsado |
| SALDO_CAPITAL | DOUBLE | Saldo de capital vigente |
| SALDO_INTERES | DOUBLE | Saldo de intereses vigente |
| SALDO_TOTAL | DOUBLE | Saldo capital mas intereses |
| FECHA_DESEMBOLSO | DATE | Fecha de desembolso |
| FECHA_VENCIMIENTO | DATE | Fecha de vencimiento |
| CUOTAS_PENDIENTES | LONG | Cuotas pendientes de pago |
| DIAS_MORA | LONG | Dias de mora actuales |
| BUCKET_MORA | STRING | AL DIA / RANGO 1 / RANGO 2 / RANGO 3 / DETERIORADO |
| CLASIFICACION_REGULATORIA | STRING | Categoria Superfinanciera: A / B / C / D / E |
| PCT_PROVISION | DOUBLE | Porcentaje de provision regulatorio |
| PROVISION_ESTIMADA | DOUBLE | Provision estimada sobre saldo capital |
| CALIFICACION_RIESGO_ORIGEN | STRING | Calificacion de riesgo de la fuente |
| PERIODO | STRING | Particion MM-YYYY |
| _FECHA_CARGA | DATE | Fecha de carga |
| _FUENTE | STRING | Fuente de origen |

---

### gold.financiero.fact_rentabilidad_cliente
Ingresos mensuales por cliente con CLTV acumulado de 12 meses. Particionada por PERIODO.

| Campo | Tipo | Descripcion |
|---|---|---|
| ID_CLIENTE | STRING | Identificador del cliente (FK dim_clientes) |
| PERIODO | STRING | Particion MM-YYYY |
| INGRESOS_INTERESES | DOUBLE | Ingresos por intereses del periodo |
| INGRESOS_COMISIONES_MOV | DOUBLE | Comisiones desde movimientos financieros |
| INGRESOS_COMISIONES_LOG | DOUBLE | Comisiones efectivamente cobradas desde log |
| INGRESO_TOTAL | DOUBLE | Suma de intereses y comisiones del periodo |
| CLTV_12M | DOUBLE | Suma de ingresos de los ultimos 12 meses por cliente |
| _FECHA_CARGA | DATE | Fecha de carga |
| _FUENTE | STRING | Fuente de origen |

---

### gold.financiero.agg_transacciones_segmento
Agregacion mensual de transacciones por segmento comercial.

| Campo | Tipo | Descripcion |
|---|---|---|
| SEGMENTO | STRING | Segmento comercial del cliente |
| PERIODO | STRING | Mes de corte MM-YYYY |
| NUM_TRANSACCIONES | LONG | Total de movimientos en el periodo |
| MONTO_TOTAL_COP | DOUBLE | Suma de montos en COP |
| MONTO_PROMEDIO_COP | DOUBLE | Ticket promedio por transaccion |
| NUM_TRANSACCIONES_SOSPECHOSAS | LONG | Transacciones con flag de anomalia |
| NUM_CLIENTES_ACTIVOS | LONG | Clientes con al menos una transaccion |

---

### gold.financiero.agg_cartera_mora
Agregacion mensual de cartera por bucket de mora y clasificacion regulatoria.

| Campo | Tipo | Descripcion |
|---|---|---|
| PERIODO | STRING | Mes de corte MM-YYYY |
| BUCKET_MORA | STRING | Rango de mora |
| CLASIFICACION_REGULATORIA | STRING | Categoria Superfinanciera |
| NUM_OBLIGACIONES | LONG | Creditos en el bucket |
| NUM_CLIENTES | LONG | Clientes distintos en el bucket |
| SALDO_CAPITAL_TOTAL | DOUBLE | Saldo de capital expuesto |
| SALDO_INTERES_TOTAL | DOUBLE | Saldo de intereses acumulados |
| SALDO_TOTAL | DOUBLE | Saldo capital mas intereses |
| PROVISION_TOTAL | DOUBLE | Provision requerida total |
| PCT_COBERTURA | DOUBLE | Provision sobre saldo capital en porcentaje |

---

### gold.financiero.agg_rentabilidad_producto_canal
Agregacion mensual de rentabilidad por producto y canal digital.

| Campo | Tipo | Descripcion |
|---|---|---|
| PERIODO | STRING | Mes de corte MM-YYYY |
| DESCRIPCION_PRODUCTO | STRING | Nombre del producto |
| FAMILIA_PRODUCTO | STRING | CREDITO / AHORRO / TRANSACCIONAL |
| CODIGO_CANAL | STRING | Canal: APP MOVIL / PORTAL WEB / CORRESPONSAL |
| NUM_CLIENTES | LONG | Clientes que usaron el producto en el canal |
| NUM_TRANSACCIONES | LONG | Total de transacciones |
| INGRESO_BRUTO_COP | DOUBLE | Suma de montos transados en COP |
| INGRESO_PROMEDIO_CLIENTE | DOUBLE | Promedio de ingresos por cliente |
| CLTV_PROMEDIO | DOUBLE | CLTV promedio de los ultimos 12 meses |
