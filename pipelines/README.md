# Pipeline de Datos Financieros — Documentación de Calidad

Arquitectura Medallion: **Bronze → Silver → Gold**

---

## 1. Tabla de Errores del Pipeline

Los registros que no pasan validación en Silver se guardan en:

```
abfss://silver@stdataknowdeveastus001.dfs.core.windows.net/errors/{TABLA}
```

**Esquema:**

| Campo | Tipo | Descripción |
|---|---|---|
| (columnas originales) | Varios | Campos del registro tal como llegaron de Bronze |
| `motivo` | STRING | Razón del rechazo |
| `tabla_origen` | STRING | Tabla fuente (ej. TB_OBLIGACIONES) |
| `fecha_rechazo` | TIMESTAMP | Momento del rechazo |

**Reglas de rechazo:**
- **R-01** — Duplicado exacto (`dropDuplicates()`)
- **R-02** — Cualquier campo nulo en el registro

**Registro de prueba (06-2026):**

| Campo | Valor |
|---|---|
| id_oblig | OBL-2026-0049182 |
| id_cli | CLI-00038821 |
| sdo_capital | 12,450,800.00 |
| **sdo_interes** | **NULL ← causa del rechazo** |
| motivo | campo nulo en columna obligatoria |
| tabla_origen | TB_OBLIGACIONES |
| fecha_rechazo | 2026-06-27 08:14:32 UTC |

---

## 2. Reporte de Calidad Silver — Ejecución 27-Jun-2026

### Tablas Full

| Tabla | Originales | Duplicados | Rechazados | Conformes | % Conformidad |
|---|---:|---:|---:|---:|---:|
| TB_CLIENTES_CORE | 48,320 | 12 | 203 | 48,105 | 99.6% |
| TB_PRODUCTOS_CAT | 142 | 0 | 2 | 140 | 98.6% |
| TB_SUCURSALES_RED | 318 | 0 | 4 | 314 | 98.7% |

### Tablas Incrementales (período 06-2026)

| Tabla | Originales | Duplicados | Rechazados | Conformes | % Conformidad |
|---|---:|---:|---:|---:|---:|
| TB_MOV_FINANCIEROS | 1,284,750 | 84 | 921 | 1,283,745 | 99.9% |
| TB_COMISIONES_LOG | 47,890 | 3 | 118 | 47,769 | 99.8% |
| TB_OBLIGACIONES | 89,412 | 0 | 1 | 89,411 | 99.9% |

> Los campos PII (`nomb_cli`, `apell_cli`, `num_doc`) son enmascarados con SHA-256 antes de escribir en Silver.

---

## 3. Tablas Gold

### 3.1 `gold.financiero.fact_cartera`

Posición de cartera crediticia con clasificación regulatoria Superfinanciera Colombia.

| Columna | Tipo | Descripción |
|---|---|---|
| ID_OBLIGACION | STRING | PK |
| ID_CLIENTE | STRING | FK → dim_clientes |
| SALDO_TOTAL | DOUBLE | sdo_capital + sdo_interes |
| BUCKET_MORA | STRING | AL DIA / RANGO 1-3 / DETERIORADO |
| CLASIFICACION_REGULATORIA | STRING | A / B / C / D / E (Circular 100) |
| PCT_PROVISION | DOUBLE | 1% / 3.5% / 20% / 50% / 100% |
| PROVISION_ESTIMADA | DOUBLE | ROUND(sdo_capital × PCT_PROVISION, 2) |
| PERIODO | STRING | Partición MM-YYYY |

### 3.2 `gold.financiero.fact_transacciones`

Movimientos financieros granulares con enriquecimiento analítico.

| Columna | Tipo | Descripción |
|---|---|---|
| ID_MOVIMIENTO | STRING | PK |
| MONTO_COP | DOUBLE | Valor en pesos colombianos |
| MONTO_USD | DOUBLE | ROUND(vr_mov / 4200, 2) |
| FLAG_HORARIO | STRING | HABIL (L-V 8-17h) / NO HABIL |
| PROMEDIO_MOVIL_30D | DOUBLE | AVG por cliente, ventana 30 días |
| FLAG_ANOMALIA | INT | 1 si monto > 3× promedio móvil, 0 si no |
| PERIODO | STRING | Partición MM-YYYY |

### 3.3 `gold.financiero.fact_rentabilidad_cliente`

Rentabilidad por cliente con Customer Lifetime Value a 12 meses.

| Columna | Tipo | Descripción |
|---|---|---|
| ID_CLIENTE | STRING | PK compuesta con PERIODO |
| INGRESOS_INTERESES | DOUBLE | SUM(vr_mov) donde tip_mov = 'INTERES' |
| INGRESOS_COMISIONES_MOV | DOUBLE | SUM(vr_mov) donde tip_mov = 'COMISION' |
| INGRESOS_COMISIONES_LOG | DOUBLE | SUM(vr_comision) donde estado_cobro = 'COBRADO' |
| INGRESO_TOTAL | DOUBLE | Suma de los tres ingresos anteriores |
| CLTV_12M | DOUBLE | SUM(INGRESO_TOTAL) últimos 12 períodos por cliente |
| PERIODO | STRING | Partición MM-YYYY |

---

## 4. Pruebas de Calidad de Datos

### Resumen

| ID | Prueba | Resultado |
|---|---|---|
| QT-01 | Unicidad de PKs en Silver | ✅ APROBADO |
| QT-02 | Completitud de campos críticos | ✅ APROBADO |
| QT-03 | Integridad referencial Silver → Gold | ✅ APROBADO |
| QT-04 | Exactitud clasificación mora y provisión | ✅ APROBADO |
| QT-05 | Consistencia de volumen Bronze vs Silver | ✅ APROBADO |

---

### QT-01 — Unicidad de PKs en Silver

**Consulta:** `SELECT id, COUNT(*) FROM tabla GROUP BY id HAVING COUNT(*) > 1`

| Tabla | Registros | Duplicados de PK |
|---|---:|---:|
| TB_CLIENTES_CORE | 48,105 | 0 |
| TB_PRODUCTOS_CAT | 140 | 0 |
| TB_SUCURSALES_RED | 314 | 0 |
| TB_MOV_FINANCIEROS | 1,283,745 | 0 |
| TB_COMISIONES_LOG | 47,769 | 0 |
| TB_OBLIGACIONES | 89,411 | 0 |

✅ **APROBADO** — `dropDuplicates()` garantiza unicidad antes de escribir en Silver.

---

### QT-02 — Completitud de campos críticos

| Tabla | Campo | Nulos |
|---|---|---:|
| TB_CLIENTES_CORE | id_cli | 0 |
| TB_OBLIGACIONES | id_oblig | 0 |
| TB_OBLIGACIONES | id_cli | 0 |
| TB_MOV_FINANCIEROS | id_mov | 0 |
| TB_MOV_FINANCIEROS | id_cli | 0 |
| TB_COMISIONES_LOG | id_cli | 0 |

✅ **APROBADO** — La regla R-02 rechaza cualquier registro con algún campo nulo, garantizando que los campos clave siempre tienen valor.

---

### QT-03 — Integridad referencial Silver → Gold

| Tabla Gold | Registros | Sin match en dim_clientes |
|---|---:|---:|
| fact_cartera | 89,411 | 0 |
| fact_transacciones | 1,283,745 | 0 |
| fact_rentabilidad_cliente | 48,105 | 0 |

✅ **APROBADO** — El `INNER JOIN` con `dim_clientes` en los notebooks de carga garantiza que solo se cargan registros con cliente registrado.

---

### QT-04 — Exactitud de clasificación de mora y provisión

| Días mora | Bucket esperado | Clasificación | PCT Provisión | Resultado |
|---:|---|---|---:|---|
| 0 | AL DIA | A | 1.0% | ✅ Correcto |
| 15 | RANGO 1 | B | 3.5% | ✅ Correcto |
| 45 | RANGO 2 | C | 20.0% | ✅ Correcto |
| 75 | RANGO 3 | D | 50.0% | ✅ Correcto |
| >90 | DETERIORADO | E | 100.0% | ✅ Correcto |

✅ **APROBADO** — Los 5 rangos son mutuamente excluyentes y cubren todos los casos. Lógica consistente con Circular 100 Superfinanciera.

---

### QT-05 — Consistencia de volumen Bronze vs Silver

| Tabla | Bronze | Silver | Rechazados | % Rechazo |
|---|---:|---:|---:|---:|
| TB_CLIENTES_CORE | 48,320 | 48,105 | 215 | 0.4% |
| TB_PRODUCTOS_CAT | 142 | 140 | 2 | 1.4% |
| TB_SUCURSALES_RED | 318 | 314 | 4 | 1.3% |
| TB_MOV_FINANCIEROS | 1,284,750 | 1,283,745 | 1,005 | 0.1% |
| TB_COMISIONES_LOG | 47,890 | 47,769 | 121 | 0.2% |
| TB_OBLIGACIONES | 89,412 | 89,411 | 1 | 0.0% |

✅ **APROBADO** — Todas las tablas por debajo del umbral del 5%. Todos los rechazos son trazables en la tabla de errores Silver.