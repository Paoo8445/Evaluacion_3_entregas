
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException
from fastapi import File, UploadFile, Form
import os
from datetime import datetime
import pymysql
import hashlib

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # permitir todos los orígenes
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_connection():
    connection = pymysql.connect(
        host="localhost",
        user="root",
        password="",
        database="eva3",
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection



class LoginData(BaseModel):
    email: str
    password: str



# Ruta de prueba
# @app.get("/ping")
# def ping():
#     return {"mensaje": "API funcionando correctamente"}



@app.get("/agentes")
def obtener_agentes():
    
    conn = get_connection()#abre la conexión
    with conn.cursor() as cursor:
        cursor.execute("SELECT id_agente, nombre, email, activo FROM agentes")
        agentes = cursor.fetchall()  # obtiene todas las filas

    conn.close()# cerrar conexión
    return agentes




@app.post("/login")
def login(data: LoginData):
    
    conn = get_connection()
    pass_encri = hashlib.sha256(data.password.encode()).hexdigest()
    
    with conn.cursor() as cursor:
        sql = "SELECT * FROM agentes WHERE email = %s AND password_hash = %s AND activo = 1"
        cursor.execute(sql, (data.email, pass_encri))
        agente = cursor.fetchone()

    conn.close()

    if agente:
        return {
            "mensaje": "Login correcto",
            "id_agente": agente["id_agente"],
            "nombre": agente["nombre"]
        }
    else:
        raise HTTPException(status_code=401, detail="Credenciales incorrectas o usuario inactivo")


@app.get("/paquetes/{id_agente}")
def obtener_paquetes(id_agente: int):
    
    conn = get_connection()
    with conn.cursor() as cursor:
        sql = """
            SELECT id_paquete, codigo, direccion, estado
            FROM paquetes
            WHERE id_agente = %s AND estado = 'pendiente'
        """
        cursor.execute(sql, (id_agente,))
        paquetes = cursor.fetchall()
    conn.close()
    return paquetes



@app.post("/entregas")
async def registrar_entrega(
    id_paquete: int = Form(...),
    id_agente: int = Form(...),
    latitud: float = Form(...),
    longitud: float = Form(...),
    foto: UploadFile = File(...)
):
    #Detecta la extensión 
    extension = foto.filename.split(".")[-1].lower()
    ext_permitidas = ["jpg", "jpeg", "png"]

    if extension not in ext_permitidas:
        raise HTTPException(status_code=400, detail="Formato de imagen no permitido. Usa JPG o PNG.")

    #Crea el nombre del archivo
    nombre_archivo = f"{id_paquete}_{datetime.now().timestamp()}.{extension}"
    ruta_archivo = os.path.join("uploads", nombre_archivo)
    
    #guarda la fotito
    with open(ruta_archivo, "wb") as archivo:
        contenido = await foto.read()
        archivo.write(contenido)

    #Crea registro en la tabla entregas
    conn = get_connection()
    with conn.cursor() as cursor:
        sql_entrega = """
            INSERT INTO entregas (id_paquete, id_agente, fecha_hora, latitud, longitud, foto_url)
            VALUES (%s, %s, NOW(), %s, %s, %s)
        """
        cursor.execute(sql_entrega, (id_paquete, id_agente, latitud, longitud, nombre_archivo))

        #Actualiza el estado del paquete a entregado
        sql_paquete = "UPDATE paquetes SET estado = 'entregado' WHERE id_paquete = %s"
        cursor.execute(sql_paquete, (id_paquete,))

    conn.commit()
    conn.close()

    return {"mensaje": "Entrega registrada correctamente", "foto": nombre_archivo}


@app.get("/entregas/{id_paquete}")
def ver_entregas(id_paquete: int):
    conn = get_connection()
    with conn.cursor() as cursor:
        sql = "SELECT * FROM entregas WHERE id_paquete = %s"
        cursor.execute(sql, (id_paquete,))
        entregas = cursor.fetchall()
    conn.close()
    return entregas
