import psycopg2
from tkinter import messagebox

def conectar():
    try:
        return psycopg2.connect(
            host='localhost',
            user='Grupo10',
            password='1234',
            database='Museo'
        )
    except Exception as e:
        messagebox.showerror("Error de conexión", str(e))
        return None
