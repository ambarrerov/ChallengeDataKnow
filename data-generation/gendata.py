# Databricks notebook source
# MAGIC %md
# MAGIC # FinBank S.A. — Generador de Datos Mockup
# MAGIC Ejecutar en **Classic Compute**, Databricks Runtime 13.x LTS o superior.

# COMMAND ----------

# MAGIC %pip install faker --quiet

# COMMAND ----------

# MAGIC %md ## 0. Configuración — credenciales y parámetros

# COMMAND ----------

import random, os
from datetime import datetime, timedelta, date
from dateutil.relativedelta import relativedelta
import numpy as np
import pandas as pd
from faker import Faker
# from pyspark.sql import SparkSession
from pyspark.sql import functions as F
import json

with open("config/config.json") as f:
    cfg = json.load(f)

creds       = cfg["credentials"]
DATA_CONFIG = cfg["data_config"]

# JDBC
host     = creds["host"]
port     = creds["port"]
db       = creds["db"]
user     = creds["user"]
password = creds["password"]

JDBC_URL = (
    f"jdbc:sqlserver://{host}:{port};"
    f"databaseName={db};"
    f"encrypt=true;"
    f"trustServerCertificate=false;"
)
JDBC_PROPS = {
    "user":     user,
    "password": password,
    "driver":   "com.microsoft.sqlserver.jdbc.SQLServerDriver",
}

print(f"✅ Config cargada → {host} / {db}")

# COMMAND ----------

CONFIG_PATH = "config/config.json"
 
with open(CONFIG_PATH) as f:
    cfg = json.load(f)
 
SCOPE       = cfg["key_vault"]["scope"]
KV_KEYS     = cfg["key_vault"]["keys"]
DATA_CONFIG = cfg["data_config"]
 
# Leer secretos desde Azure Key Vault (kv-dataknow-dev-eastus)
host     = dbutils.secrets.get(SCOPE, KV_KEYS["host"])
port     = dbutils.secrets.get(SCOPE, KV_KEYS["port"])
db       = dbutils.secrets.get(SCOPE, KV_KEYS["db"])
user     = dbutils.secrets.get(SCOPE, KV_KEYS["user"])
password = dbutils.secrets.get(SCOPE, KV_KEYS["password"])
 
JDBC_URL = (
    f"jdbc:sqlserver://{host}:{port};"
    f"databaseName={db};"
    f"encrypt=true;"
    f"trustServerCertificate=false;"
)
JDBC_PROPS = {
    "user":     user,
    "password": password,
    "driver":   "com.microsoft.sqlserver.jdbc.SQLServerDriver",
}

print(f"✅ Config cargada → {host} / {db}")

# COMMAND ----------

# DBTITLE 1,semilla
SEED       = DATA_CONFIG["random_seed"]
NULL_RATE  = DATA_CONFIG["null_rate"]
PAISES     = DATA_CONFIG["paises"]
MESES      = DATA_CONFIG["historico_meses"]
SCHEMA_SQL = DATA_CONFIG["schema"]
ANOMALIAS  = DATA_CONFIG["anomalias"]

random.seed(SEED)
np.random.seed(SEED)
fake = Faker(["es_CO", "es_MX", "es_ES", "es_CL", "es_AR"])
Faker.seed(SEED)

FIN    = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
INICIO = FIN - relativedelta(months=MESES)

# spark = SparkSession.builder.getOrCreate()

print(f"✅ Configuración cargada")
print(f"   Host  : {host}")
print(f"   DB    : {db}")
print(f"   Rango : {INICIO.date()} → {FIN.date()}")

# COMMAND ----------

# MAGIC %md ## 2. Funciones auxiliares

# COMMAND ----------

def maybe_null(val):
    return None if random.random() < NULL_RATE else val

def random_date(start, end):
    delta = (end - start).total_seconds()
    return start + timedelta(seconds=random.random() * delta)

def random_date_seasonal(start, end):
    d = random_date(start, end)
    pico = {12: 0.7, 3: 0.6, 8: 0.55}
    if random.random() < pico.get(d.month, 0.0):
        target = min(pico.keys(), key=lambda m: abs(m - d.month))
        try:
            d = d.replace(month=target)
        except ValueError:
            pass
    return d

def random_hora():
    pesos = [0.5,0.3,0.2,0.2,0.3,0.8,1.5,3.0,5.0,7.0,7.0,6.0,
             5.0,5.5,7.0,7.0,6.0,5.0,4.0,3.0,2.5,2.0,1.5,1.0]
    hora = random.choices(range(24), weights=pesos, k=1)[0]
    return hora, random.randint(0, 59)

def monto_transaccion(tip_mov):
    params = {
        "PAGO":          (4.5, 1.2),
        "TRANSFERENCIA": (5.0, 1.3),
        "RECARGA":       (3.8, 0.8),
        "AVANCE":        (5.5, 1.0),
        "RETIRO":        (4.8, 0.9),
        "DEPOSITO":      (5.2, 1.1),
    }
    mu, sigma = params.get(tip_mov, (4.5, 1.0))
    return round(float(np.clip(np.random.lognormal(mu, sigma), 1.0, 50_000.0)), 2)

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

# COMMAND ----------

# MAGIC %md ## 3. TB_SUCURSALES_RED

# COMMAND ----------

def generar_sucursales():
    n = DATA_CONFIG["TB_SUCURSALES_RED"]
    tipos = ["SUCURSAL", "CORRESPONSAL", "ATM", "AGENTE_DIGITAL", "OFICINA_PRINCIPAL"]
    ciudades = {
        "Colombia":  ["Bogotá","Medellín","Cali","Barranquilla","Bucaramanga","Cartagena"],
        "Mexico":    ["Ciudad de México","Guadalajara","Monterrey","Puebla","León","Tijuana"],
        "Peru":      ["Lima","Arequipa","Trujillo","Piura","Cusco","Huancayo"],
        "Chile":     ["Santiago","Valparaíso","Concepción","Talca","Temuco","Antofagasta"],
        "Argentina": ["Buenos Aires","Córdoba","Rosario","Mendoza","Tucumán","Salta"],
    }
    deptos = {
        "Colombia":  ["Cundinamarca","Antioquia","Valle","Atlántico","Santander","Bolívar"],
        "Mexico":    ["CDMX","Jalisco","Nuevo León","Puebla","Guanajuato","Veracruz"],
        "Peru":      ["Lima","Arequipa","La Libertad","Piura","Cusco","Junín"],
        "Chile":     ["Metropolitana","Valparaíso","Biobío","Maule","La Araucanía","Antofagasta"],
        "Argentina": ["Buenos Aires","Córdoba","Santa Fe","Mendoza","Tucumán","Salta"],
    }
    lat_base = {"Colombia":4.7,"Mexico":19.4,"Peru":-12.0,"Chile":-33.5,"Argentina":-34.6}
    lon_base = {"Colombia":-74.1,"Mexico":-99.1,"Peru":-77.0,"Chile":-70.7,"Argentina":-58.4}
    rows = []
    for i in range(1, n + 1):
        pais = random.choice(PAISES)
        rows.append({
            "cod_suc":   f"SUC{i:05d}",
            "nom_suc":   f"Punto {fake.city()} {i}",
            "tip_punto": random.choice(tipos),
            "ciudad":    random.choice(ciudades[pais]),
            "depto":     random.choice(deptos[pais]),
            "pais":      pais,
            "latitud":   round(lat_base[pais] + np.random.uniform(-3, 3), 6),
            "longitud":  round(lon_base[pais] + np.random.uniform(-3, 3), 6),
            "activo":    1 if random.random() > 0.05 else 0,
        })
    return pd.DataFrame(rows)

print("🏦 Generando TB_SUCURSALES_RED ...")
df_suc_pd = generar_sucursales()
write_jdbc(spark.createDataFrame(df_suc_pd), "TB_SUCURSALES_RED")
CIUDADES_VALIDAS = df_suc_pd["ciudad"].unique().tolist()
CODIGOS_SUC      = df_suc_pd["cod_suc"].tolist()

# COMMAND ----------

# MAGIC %md ## 4. TB_PRODUCTOS_CAT

# COMMAND ----------

def generar_productos():
    n = DATA_CONFIG["TB_PRODUCTOS_CAT"]
    tipos = [
        ("CREDITO_CONSUMO",   "Crédito Libre Inversión"),
        ("CREDITO_ROTATIVO",  "Crédito Rotativo"),
        ("TARJETA_DIGITAL",   "Tarjeta de Crédito Digital"),
        ("AHORRO_DIGITAL",    "Cuenta de Ahorro Digital"),
        ("PAGO_PSE",          "Pago PSE"),
        ("TRANSFERENCIA_ACH", "Transferencia ACH"),
        ("CORRESPONSALIA",    "Corresponsalía Bancaria"),
    ]
    tasas  = {"CREDITO_CONSUMO":(18,28),"CREDITO_ROTATIVO":(22,35),"TARJETA_DIGITAL":(25,40),
              "AHORRO_DIGITAL":(2,5),"PAGO_PSE":(0,0),"TRANSFERENCIA_ACH":(0,0),"CORRESPONSALIA":(0,0)}
    plazos = {"CREDITO_CONSUMO":60,"CREDITO_ROTATIVO":0,"TARJETA_DIGITAL":0,
              "AHORRO_DIGITAL":0,"PAGO_PSE":0,"TRANSFERENCIA_ACH":0,"CORRESPONSALIA":0}
    rows = []
    for i in range(n):
        tip_cod, desc = tipos[i % len(tipos)]
        lo, hi = tasas[tip_cod]
        rows.append({
            "cod_prod":        f"PROD{i+1:03d}",
            "desc_prod":       f"{desc} V{i+1}",
            "tip_prod":        tip_cod,
            "tasa_ea":         round(random.uniform(lo, hi), 2) if hi > 0 else 0.0,
            "plazo_max_meses": plazos[tip_cod],
            "cuota_min":       round(random.uniform(10, 50), 2) if hi > 0 else 0.0,
            "comision_admin":  round(random.uniform(0, 5), 2),
            "estado_prod":     "ACTIVO" if random.random() > 0.1 else "INACTIVO",
        })
    return pd.DataFrame(rows)

print("📦 Generando TB_PRODUCTOS_CAT ...")
df_prod_pd = generar_productos()
write_jdbc(spark.createDataFrame(df_prod_pd), "TB_PRODUCTOS_CAT")
CODIGOS_PROD  = df_prod_pd["cod_prod"].tolist()
PRODS_CREDITO = df_prod_pd[df_prod_pd["tip_prod"].isin(
    ["CREDITO_CONSUMO","CREDITO_ROTATIVO","TARJETA_DIGITAL"])]["cod_prod"].tolist()

# COMMAND ----------

# MAGIC %md ## 5. TB_CLIENTES_CORE

# COMMAND ----------

def generar_clientes():
    n = DATA_CONFIG["TB_CLIENTES_CORE"]
    segmentos  = ["BASICO","ESTANDAR","PREMIUM","ELITE"]
    pesos_seg  = [0.45, 0.35, 0.15, 0.05]
    estados    = ["ACTIVO","INACTIVO","BLOQUEADO","EN_MORA"]
    pesos_est  = [0.80, 0.10, 0.05, 0.05]
    canales    = ["APP_MOVIL","WEB","CORRESPONSAL","REFERIDO","CAMPANA_DIGITAL"]
    tipos_doc  = ["CC","CE","PAS","NIT"]
    ciudades   = {
        "Colombia":  ["Bogotá","Medellín","Cali","Barranquilla","Bucaramanga","Cartagena"],
        "Mexico":    ["Ciudad de México","Guadalajara","Monterrey","Puebla","León","Tijuana"],
        "Peru":      ["Lima","Arequipa","Trujillo","Piura","Cusco","Huancayo"],
        "Chile":     ["Santiago","Valparaíso","Concepción","Talca","Temuco","Antofagasta"],
        "Argentina": ["Buenos Aires","Córdoba","Rosario","Mendoza","Tucumán","Salta"],
    }
    deptos = {
        "Colombia":  ["Cundinamarca","Antioquia","Valle","Atlántico","Santander","Bolívar"],
        "Mexico":    ["CDMX","Jalisco","Nuevo León","Puebla","Guanajuato","Veracruz"],
        "Peru":      ["Lima","Arequipa","La Libertad","Piura","Cusco","Junín"],
        "Chile":     ["Metropolitana","Valparaíso","Biobío","Maule","La Araucanía","Antofagasta"],
        "Argentina": ["Buenos Aires","Córdoba","Santa Fe","Mendoza","Tucumán","Salta"],
    }
    score_rango = {"BASICO":(400,600),"ESTANDAR":(550,700),"PREMIUM":(680,800),"ELITE":(750,850)}
    dist_pais   = {"Colombia":0.30,"Mexico":0.30,"Peru":0.15,"Chile":0.15,"Argentina":0.10}
    paises_l    = list(dist_pais.keys())
    pesos_p     = list(dist_pais.values())
    edades      = np.clip(np.random.normal(38, 12, n).astype(int), 18, 80)
    rows = []
    for i in range(n):
        pais     = random.choices(paises_l, weights=pesos_p, k=1)[0]
        seg      = random.choices(segmentos, weights=pesos_seg, k=1)[0]
        edad     = int(edades[i])
        fec_nac  = (FIN - timedelta(days=edad*365 + random.randint(0,364))).date()
        fec_alta = random_date(INICIO - relativedelta(years=5), FIN).date()
        lo, hi   = score_rango[seg]
        rows.append({
            "id_cli":      f"CLI{i+1:07d}",
            "nomb_cli":    fake.first_name(),
            "apell_cli":   fake.last_name(),
            "tip_doc":     random.choice(tipos_doc),
            "num_doc":     str(random.randint(10_000_000, 1_200_000_000)),
            "fec_nac":     fec_nac,
            "fec_alta":    fec_alta,
            "cod_segmento":seg,
            "score_buro":  random.randint(lo, hi),
            "ciudad_res":  random.choice(ciudades[pais]),
            "depto_res":   maybe_null(random.choice(deptos[pais])),
            "pais":        pais,
            "estado_cli":  random.choices(estados, weights=pesos_est, k=1)[0],
            "canal_adqis": random.choice(canales),
        })
    return pd.DataFrame(rows)

print("👥 Generando TB_CLIENTES_CORE ...")
df_cli_pd = generar_clientes()
write_jdbc(spark.createDataFrame(df_cli_pd), "TB_CLIENTES_CORE")
IDS_CLIENTES = df_cli_pd["id_cli"].tolist()

# COMMAND ----------

# MAGIC %md ## 6. TB_OBLIGACIONES

# COMMAND ----------

def generar_obligaciones():
    n = DATA_CONFIG["TB_OBLIGACIONES"]
    calif_mora = {(0,30):"A",(31,60):"B",(61,90):"C",(91,180):"D",(181,9999):"E"}
    montos_seg = {"BASICO":(200,3_000),"ESTANDAR":(500,10_000),
                  "PREMIUM":(2_000,50_000),"ELITE":(10_000,200_000)}
    seg_dict   = dict(zip(df_cli_pd["id_cli"], df_cli_pd["cod_segmento"]))
    rows = []
    for i in range(n):
        id_cli   = random.choice(IDS_CLIENTES)
        cod_prod = random.choice(PRODS_CREDITO) if PRODS_CREDITO else random.choice(CODIGOS_PROD)
        seg      = seg_dict.get(id_cli, "BASICO")
        lo, hi   = montos_seg[seg]
        vr_aprobado    = round(random.uniform(lo, hi), 2)
        vr_desembolsado= round(vr_aprobado * random.uniform(0.7, 1.0), 2)
        sdo_capital    = round(vr_desembolsado * random.uniform(0.0, 1.0), 2)
        fec_desembolso = random_date_seasonal(INICIO, FIN).date()
        plazo          = random.choice([12,24,36,48,60])
        fec_venc       = (fec_desembolso + relativedelta(months=plazo))
        dias_mora      = 0 if random.random() < 0.85 else int(np.random.exponential(45))
        calif          = next((c for (lo_m,hi_m),c in calif_mora.items() if lo_m<=dias_mora<=hi_m), "A")
        cuotas_pagadas = max(0, min(plazo-1, int((FIN.date()-fec_desembolso).days/30)))
        rows.append({
            "id_oblig":        f"OBL{i+1:08d}",
            "id_cli":          id_cli,
            "cod_prod":        cod_prod,
            "vr_aprobado":     vr_aprobado,
            "vr_desembolsado": vr_desembolsado,
            "sdo_capital":     sdo_capital,
            "sdo_interes":     maybe_null(round(sdo_capital * random.uniform(0.01, 0.05), 2)),
            "fec_desembolso":  fec_desembolso,
            "fec_venc":        fec_venc,
            "dias_mora_act":   dias_mora,
            "num_cuotas_pend": plazo - cuotas_pagadas,
            "calif_riesgo":    calif,
            "ciudad":          maybe_null(random.choice(CIUDADES_VALIDAS)),
            "pais":            maybe_null(random.choice(PAISES)),
        })
    df = pd.DataFrame(rows)
    # Anomalía 1: sdo_capital > vr_aprobado
    idx_anom = random.sample(range(len(df)), ANOMALIAS["montos_inconsistentes"])
    for idx in idx_anom:
        df.at[idx, "sdo_capital"] = round(df.at[idx, "vr_aprobado"] * random.uniform(1.1, 2.0), 2)
    print(f"  ⚠️  Anomalía 1: {ANOMALIAS['montos_inconsistentes']} registros sdo_capital > vr_aprobado")
    return df

print("💳 Generando TB_OBLIGACIONES ...")
df_obl_pd = generar_obligaciones()
write_jdbc(spark.createDataFrame(df_obl_pd), "TB_OBLIGACIONES")
IDS_CUENTAS = [f"CTA{i:010d}" for i in range(1, DATA_CONFIG["TB_MOV_FINANCIEROS"] // 10 + 1)]

# COMMAND ----------

# MAGIC %md ## 7. TB_MOV_FINANCIEROS

# COMMAND ----------

def generar_batch_movimientos(batch_size, offset):
    tipos_mov = ["PAGO","TRANSFERENCIA","RECARGA","AVANCE","RETIRO","DEPOSITO"]
    pesos_mov = [0.30,0.25,0.20,0.10,0.10,0.05]
    canales   = ["APP_MOVIL","WEB","CORRESPONSAL","ATM","USSD"]
    pesos_can = [0.45,0.25,0.15,0.10,0.05]
    estados   = ["APROBADA","RECHAZADA","PENDIENTE","REVERSADA"]
    pesos_est = [0.88,0.06,0.04,0.02]
    rows = []
    for i in range(batch_size):
        tip_mov = random.choices(tipos_mov, weights=pesos_mov, k=1)[0]
        h, m    = random_hora()
        fec     = random_date_seasonal(INICIO, FIN)
        fec     = fec.replace(hour=h, minute=m, second=random.randint(0,59))
        rows.append({
            "id_mov":         f"MOV{offset+i+1:010d}",
            "id_cli":         random.choice(IDS_CLIENTES),
            "cod_prod":       random.choice(CODIGOS_PROD),
            "num_cuenta":     random.choice(IDS_CUENTAS),
            "fec_mov":        fec.date(),
            "hra_mov":        fec.strftime("%H:%M:%S"),
            "vr_mov":         monto_transaccion(tip_mov),
            "tip_mov":        tip_mov,
            "cod_canal":      random.choices(canales, weights=pesos_can, k=1)[0],
            "cod_ciudad":     maybe_null(random.choice(CIUDADES_VALIDAS)),
            "cod_estado_mov": random.choices(estados, weights=pesos_est, k=1)[0],
            "id_dispositivo": maybe_null(f"DEV{random.randint(1,500_000):07d}"),
        })
    return pd.DataFrame(rows)

print("💸 Generando TB_MOV_FINANCIEROS ...")
N_MOV    = DATA_CONFIG["TB_MOV_FINANCIEROS"]
BATCH_SZ = 50_000

for batch_num, offset in enumerate(range(0, N_MOV, BATCH_SZ)):
    sz  = min(BATCH_SZ, N_MOV - offset)
    pdf = generar_batch_movimientos(sz, offset)
    # Anomalía 2: fechas año 2099 (solo batch 0)
    if batch_num == 0:
        idx_f = random.sample(range(len(pdf)), ANOMALIAS["fechas_fuera_rango"])
        for idx in idx_f:
            pdf.at[idx, "fec_mov"] = date(2099, random.randint(1,12), random.randint(1,28))
        print(f"  ⚠️  Anomalía 2: {ANOMALIAS['fechas_fuera_rango']} fechas año 2099 inyectadas")
    mode = "overwrite" if batch_num == 0 else "append"
    write_jdbc(spark.createDataFrame(pdf), "TB_MOV_FINANCIEROS", mode=mode)
    print(f"  📊 Batch {batch_num+1}/{(N_MOV//BATCH_SZ)+1} completado")

# Anomalía 3: duplicados — releer muestra y reinsertar
print(f"  ⚠️  Anomalía 3: insertando {ANOMALIAS['duplicados_mov']} duplicados ...")
dup_df = (spark.read.format("jdbc")
    .option("url",      JDBC_URL)
    .option("dbtable",  f"(SELECT TOP {ANOMALIAS['duplicados_mov']} * FROM {SCHEMA_SQL}.TB_MOV_FINANCIEROS ORDER BY NEWID()) t")
    .option("user",     JDBC_PROPS["user"])
    .option("password", JDBC_PROPS["password"])
    .option("driver",   JDBC_PROPS["driver"])
    .load())
write_jdbc(dup_df, "TB_MOV_FINANCIEROS", mode="append")

# COMMAND ----------

# MAGIC %md ## 8. TB_COMISIONES_LOG

# COMMAND ----------

def generar_comisiones():
    n = DATA_CONFIG["TB_COMISIONES_LOG"]
    tipos   = ["ADMIN","APERTURA","TRANSACCIONAL","MORA","PREPAGO"]
    pesos_t = [0.40,0.15,0.25,0.15,0.05]
    estados = ["COBRADA","PENDIENTE","EXONERADA","REVERTIDA"]
    pesos_e = [0.75,0.12,0.08,0.05]
    montos  = {"ADMIN":(5,50),"APERTURA":(10,100),"TRANSACCIONAL":(1,15),
               "MORA":(20,200),"PREPAGO":(5,80)}
    rows = []
    for i in range(n):
        tip = random.choices(tipos, weights=pesos_t, k=1)[0]
        lo, hi = montos[tip]
        rows.append({
            "id_comision":  f"COM{i+1:09d}",
            "id_cli":       random.choice(IDS_CLIENTES),
            "cod_prod":     random.choice(CODIGOS_PROD),
            "fec_cobro":    random_date_seasonal(INICIO, FIN).date(),
            "vr_comision":  round(random.uniform(lo, hi), 2),
            "tip_comision": tip,
            "estado_cobro": random.choices(estados, weights=pesos_e, k=1)[0],
            "id_mov_ref":   maybe_null(f"MOV{random.randint(1, N_MOV):010d}"),
            "pais":         maybe_null(random.choice(PAISES)),
        })
    return pd.DataFrame(rows)

print("💰 Generando TB_COMISIONES_LOG ...")
df_com_pd = generar_comisiones()
write_jdbc(spark.createDataFrame(df_com_pd), "TB_COMISIONES_LOG")

# COMMAND ----------

# MAGIC %md ## 9. Validaciones post-carga

# COMMAND ----------

def validar_tabla(tabla, expected_min):
    try:
        df = (spark.read.format("jdbc")
            .option("url",      JDBC_URL)
            .option("dbtable",  f"{SCHEMA_SQL}.{tabla}")
            .option("user",     JDBC_PROPS["user"])
            .option("password", JDBC_PROPS["password"])
            .option("driver",   JDBC_PROPS["driver"])
            .load())
        cnt = df.count()
        status = "✅" if cnt >= expected_min else "⚠️"
        print(f"  {status} {tabla:<25} {cnt:>10,} registros")
        return cnt
    except Exception as e:
        print(f"  ❌ {tabla:<25} Error: {e}")
        return 0

print("\n" + "="*55)
print("📋 VALIDACIÓN FINAL — FinBank Mockup")
print("="*55)

total = 0
total += validar_tabla("TB_SUCURSALES_RED",  DATA_CONFIG["TB_SUCURSALES_RED"])
total += validar_tabla("TB_PRODUCTOS_CAT",   DATA_CONFIG["TB_PRODUCTOS_CAT"])
total += validar_tabla("TB_CLIENTES_CORE",   DATA_CONFIG["TB_CLIENTES_CORE"])
total += validar_tabla("TB_OBLIGACIONES",    DATA_CONFIG["TB_OBLIGACIONES"])
total += validar_tabla("TB_MOV_FINANCIEROS", DATA_CONFIG["TB_MOV_FINANCIEROS"])
total += validar_tabla("TB_COMISIONES_LOG",  DATA_CONFIG["TB_COMISIONES_LOG"])
print(f"  {'─'*50}")
print(f"  {'TOTAL':<25} {total:>10,} registros")
print("="*55)

# COMMAND ----------

# Validación de integridad referencial
print("\n🔍 Validaciones de integridad referencial:")

checks = [
    ("Movimientos sin cliente válido",
     f"(SELECT COUNT(*) AS n FROM {SCHEMA_SQL}.TB_MOV_FINANCIEROS m LEFT JOIN {SCHEMA_SQL}.TB_CLIENTES_CORE c ON m.id_cli=c.id_cli WHERE c.id_cli IS NULL) t"),
    ("Obligaciones sin cliente válido",
     f"(SELECT COUNT(*) AS n FROM {SCHEMA_SQL}.TB_OBLIGACIONES o LEFT JOIN {SCHEMA_SQL}.TB_CLIENTES_CORE c ON o.id_cli=c.id_cli WHERE c.id_cli IS NULL) t"),
    ("Comisiones sin cliente válido",
     f"(SELECT COUNT(*) AS n FROM {SCHEMA_SQL}.TB_COMISIONES_LOG cm LEFT JOIN {SCHEMA_SQL}.TB_CLIENTES_CORE c ON cm.id_cli=c.id_cli WHERE c.id_cli IS NULL) t"),
]
for desc, query in checks:
    df_c = (spark.read.format("jdbc")
        .option("url",      JDBC_URL)
        .option("dbtable",  query)
        .option("user",     JDBC_PROPS["user"])
        .option("password", JDBC_PROPS["password"])
        .option("driver",   JDBC_PROPS["driver"])
        .load())
    n = df_c.collect()[0]["n"]
    status = "✅" if n == 0 else "⚠️"
    print(f"  {status} {desc}: {n} huérfanos")

# COMMAND ----------

# Validación de anomalías
print("\n⚠️  Validación de anomalías documentadas:")

anomalia_checks = [
    ("Anomalía 1 — sdo_capital > vr_aprobado",
     f"(SELECT COUNT(*) AS n FROM {SCHEMA_SQL}.TB_OBLIGACIONES WHERE sdo_capital > vr_aprobado) t",
     ANOMALIAS["montos_inconsistentes"]),
    ("Anomalía 2 — fechas año 2099",
     f"(SELECT COUNT(*) AS n FROM {SCHEMA_SQL}.TB_MOV_FINANCIEROS WHERE YEAR(fec_mov) > 2030) t",
     ANOMALIAS["fechas_fuera_rango"]),
    ("Anomalía 3 — id_mov duplicados",
     f"(SELECT COUNT(*) AS n FROM (SELECT id_mov FROM {SCHEMA_SQL}.TB_MOV_FINANCIEROS GROUP BY id_mov HAVING COUNT(*)>1) x) t",
     ANOMALIAS["duplicados_mov"]),
]
for desc, query, expected in anomalia_checks:
    df_a = (spark.read.format("jdbc")
        .option("url",      JDBC_URL)
        .option("dbtable",  query)
        .option("user",     JDBC_PROPS["user"])
        .option("password", JDBC_PROPS["password"])
        .option("driver",   JDBC_PROPS["driver"])
        .load())
    n = df_a.collect()[0]["n"]
    status = "✅" if n > 0 else "❌"
    print(f"  {status} {desc}: {n} encontrados (esperado ≥ {expected})")

print("\n🟢 Pipeline finalizado exitosamente")
