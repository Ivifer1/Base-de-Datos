import psycopg2
from tkinter import messagebox

def conectar():
    try:
        return psycopg2.connect(
            host='localhost',
            user='postgres',
            password='15022005',
            database='Museo'
        )
    except Exception as e:
        messagebox.showerror("Error de conexión", str(e))
        return None
