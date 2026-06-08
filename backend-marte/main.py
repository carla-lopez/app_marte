from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import mysql.connector

app = FastAPI()

# --- CONFIGURACIÓN ---
class LoginRequest(BaseModel):
    email: str
    password: str

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="1234",      # <--- TU CONTRASEÑA
        database="app_marte"
    )

@app.get("/")
def read_root():
    return {"mensaje": "API Marte Online 🚀"}

# --- 1. LOGIN ---
@app.post("/login")
def login(request: LoginRequest):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = "SELECT * FROM usuarios WHERE email = %s AND password = %s"
        cursor.execute(query, (request.email, request.password))
        user = cursor.fetchone()
        
        cursor.close()
        conn.close()

        if user:
            return {
                "status": "ok",
                "usuario": {
                    "id": user['id'],
                    "nombre": user['nombre_completo'],
                    "rol": user['rol']
                }
            }
        else:
            raise HTTPException(status_code=401, detail="Credenciales incorrectas")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- 2. RUTINA COMPLETA ---
@app.get("/rutina/{usuario_id}")
def obtener_rutina_activa(usuario_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # A. Buscar Rutina Activa
        query_rutina = """
            SELECT id, microciclo, semanas_transcurridas, fecha_inicio, fecha_fin 
            FROM rutinas 
            WHERE alumno_id = %s AND estado = 'activa'
            LIMIT 1
        """
        cursor.execute(query_rutina, (usuario_id,))
        rutina = cursor.fetchone()

        if not rutina:
            return {"mensaje": "No tienes rutinas activas."}

        # B. Buscar Días
        query_dias = """
            SELECT id, numero_dia, notas_atleta, duracion_minutos 
            FROM rutina_dias 
            WHERE rutina_id = %s 
            ORDER BY numero_dia ASC
        """
        cursor.execute(query_dias, (rutina['id'],))
        dias = cursor.fetchall()

        # C. Buscar Ejercicios y Series para cada día
        lista_dias_completa = []

        for dia in dias:
            query_ejercicios = """
                SELECT re.id, re.orden_numerico, re.orden_letra, re.tecnica_nota, re.descanso_segundos, re.rpe_objetivo,
                       e.nombre as nombre_ejercicio,e.grupo_muscular,e.es_wod,e.tipo_medida, e.url_video, e.descripcion
                FROM rutina_ejercicios re
                JOIN ejercicios e ON re.ejercicio_id = e.id
                WHERE re.dia_id = %s
                ORDER BY re.orden_numerico ASC
            """
            cursor.execute(query_ejercicios, (dia['id'],))
            ejercicios = cursor.fetchall()

            lista_ejercicios_completa = []
            for ejercicio in ejercicios:
                query_series = """
                    SELECT id, numero_serie, kg_real, reps_real, rpe_real
                    FROM rutina_series
                    WHERE rutina_ejercicio_id = %s
                    ORDER BY numero_serie ASC
                """
                cursor.execute(query_series, (ejercicio['id'],))
                series = cursor.fetchall()
                
                ejercicio['series'] = series
                lista_ejercicios_completa.append(ejercicio)

            dia['ejercicios'] = lista_ejercicios_completa
            lista_dias_completa.append(dia)

        return {
            "info_rutina": rutina,
            "dias": lista_dias_completa
        }

    except Exception as e:
        return {"error": str(e)}
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()
            
# --- 3. ACTUALIZAR SERIES (GUARDAR DATOS) ---

# Primero, definimos qué forma tienen los datos que nos va a mandar Flutter
class SerieUpdate(BaseModel):
    id_serie: int  # Necesitamos saber QUÉ serie es (su ID único en la DB)
    kg: Optional[float] = None
    reps: Optional[int] = None
    rpe: Optional[int] = None

@app.put("/actualizar-series")
def actualizar_series(series: List[SerieUpdate]):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Recorremos la lista de series que nos mandó el celular
        for item in series:
            # SQL para actualizar esa fila específica
            query = """
                UPDATE rutina_series 
                SET kg_real = %s, reps_real = %s, rpe_real = %s
                WHERE id = %s
            """
            cursor.execute(query, (item.kg, item.reps, item.rpe, item.id_serie))
        
        conn.commit() # ¡IMPORTANTE! Confirmar los cambios en la DB
        return {"mensaje": "Datos guardados correctamente ✅"}

    except Exception as e:
        conn.rollback() # Si falla, deshacer todo
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()
        
# --- 4. PIZARRA GRUPAL DEL DÍA ---
@app.get("/pizarra/hoy")
def obtener_pizarra_hoy():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Buscamos el último registro ingresado (el más nuevo)
        query = """
            SELECT contenido, DATE_FORMAT(fecha, '%d/%m/%Y') as fecha_formateada
            FROM pizarra_diaria 
            ORDER BY id DESC 
            LIMIT 1
        """
        cursor.execute(query)
        pizarra = cursor.fetchone()

        if not pizarra:
            # Si el profe no escribió nada hoy, mandamos un mensaje por defecto
            return {"contenido": "¡Hola equipo! Hoy día de descanso activo o técnica.", "fecha_formateada": ""}
        
        return pizarra

    except Exception as e:
        return {"error": str(e)}
    finally:
        cursor.close()
        conn.close()