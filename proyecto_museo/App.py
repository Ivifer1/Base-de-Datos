import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import os
import sys

# Rutas a las carpetas de reportes y generadores
ruta_reportes = os.path.join(os.path.dirname(__file__), 'Reportes')
ruta_ticket = os.path.join(os.path.dirname(__file__), 'Generador')

if ruta_reportes not in sys.path:
    sys.path.append(ruta_reportes)

if ruta_ticket not in sys.path:
    sys.path.append(ruta_ticket)

# Importación de interfaces
from reporte_ficha_empleado import interfaz_reporte_ficha_empleado
from reporte_estrcutura_org import interfaz_estructura_organizacional
from reporte_estructura_fisica import interfaz_estructura_fisica
from reporte_ficha_museo import interfaz_ficha_museo

def abrir_formulario(ruta_relativa):
    """Ejecuta un archivo Python si existe."""
    ruta_absoluta = os.path.join(os.path.dirname(__file__), ruta_relativa)
    if not os.path.exists(ruta_absoluta):
        messagebox.showerror("Error", f"No se encontró el archivo:\n{ruta_relativa}")
        return
    try:
        subprocess.Popen(["python", ruta_absoluta])
    except Exception as e:
        messagebox.showerror("Error al ejecutar", f"No se pudo abrir el formulario:\n{e}")

def abrir_tickets_entrada(ruta_relativa):
    """Abre el formulario de Tickets de Entrada"""
    ruta_absoluta = os.path.join(os.path.dirname(__file__), ruta_relativa)
    print("Ruta buscada:", ruta_absoluta)  # Ayuda para depurar

    if not os.path.exists(ruta_absoluta):
        messagebox.showerror("Error", f"No se encontró el archivo:\n{ruta_absoluta}")
        return
    try:
        subprocess.Popen(["python", ruta_absoluta])
    except Exception as e:
        messagebox.showerror("Error al ejecutar", f"No se pudo abrir el formulario:\n{e}")

def limpiar_frame(frame):
    """Limpia todos los widgets dentro de un frame."""
    for widget in frame.winfo_children():
        widget.destroy()

def mostrar_submenu_formularios():
    limpiar_frame(content_frame)

    tk.Label(content_frame, text="Seleccione un formulario:", font=("Arial", 16), bg="#f9f9f9", pady=20).pack()

    marco_botones_submenu = tk.Frame(content_frame, bg="#f9f9f9")
    marco_botones_submenu.pack()

    opciones = {
        "Artista": "Formulario/artista.py",
        "Evento": "Formulario/evento.py",
        "Programa de Mantenimiento": "Formulario/programa_mantenimiento.py",
        "Estructura Física del Museo": "Formulario/estructura_fisica.py",
    }

    for nombre, ruta in opciones.items():
        tk.Button(
            marco_botones_submenu,
            text=nombre,
            width=30,
            height=2,
            bg="#e24ac9",
            fg="white",
            relief="flat",
            command=lambda r=ruta: abrir_formulario(r)
        ).pack(pady=5)

    tk.Button(
        content_frame,
        text="Volver al Menú Principal",
        font=("Arial", 12),
        bg="#555555",
        fg="white",
        relief="flat",
        command=mostrar_menu_principal
    ).pack(pady=20)

def mostrar_submenu_reportes():
    limpiar_frame(content_frame)

    tk.Label(content_frame, text="Seleccione un reporte:", font=("Arial", 16), bg="#f9f9f9", pady=20).pack()

    marco_botones_reportes = tk.Frame(content_frame, bg="#f9f9f9")
    marco_botones_reportes.pack()

    opciones_reportes = {
        "Ficha empleado": interfaz_reporte_ficha_empleado,
        "Ficha museo": interfaz_ficha_museo,
        "Estructura organizacional": interfaz_estructura_organizacional,
        "Estructura física": interfaz_estructura_fisica,
    }

    for nombre, accion in opciones_reportes.items():
        tk.Button(
            marco_botones_reportes,
            text=nombre,
            width=30,
            height=2,
            bg="#C816DC",
            fg="white",
            relief="flat",
            command=accion
        ).pack(pady=5)

    tk.Button(
        content_frame,
        text="Volver al Menú Principal",
        font=("Arial", 12),
        bg="#555555",
        fg="white",
        relief="flat",
        command=mostrar_menu_principal
    ).pack(pady=20)

def mostrar_menu_principal():
    limpiar_frame(content_frame)

    tk.Label(
        content_frame,
        text="Bienvenido al sistema de gestión de los museos",
        font=("Arial", 18, "bold"),
        bg="#f5f5f5",
        fg="#333"
    ).pack(pady=20)

    tk.Label(
        content_frame,
        text="A continuación seleccione una opción",
        font=("Arial", 14),
        bg="#f5f5f5",
        fg="#666"
    ).pack(pady=10)

    marco_botones_principal = tk.Frame(content_frame, bg="#f5f5f5")
    marco_botones_principal.pack(pady=30)

    tk.Button(
        marco_botones_principal,
        text="Formularios",
        font=("Arial", 14),
        width=15,
        height=2,
        bg="#e24ac9",
        fg="white",
        relief="flat",
        command=mostrar_submenu_formularios
    ).pack(side="left", padx=20)

    tk.Button(
        marco_botones_principal,
        text="Reportes",
        font=("Arial", 14),
        width=15,
        height=2,
        bg="#C816DC",
        fg="white",
        relief="flat",
        command=mostrar_submenu_reportes
    ).pack(side="left", padx=20)

    tk.Button(
        marco_botones_principal,
        text="Tickets de entrada",
        font=("Arial", 14),
        width=18,
        height=2,
        bg="#3A86FF",
        fg="white",
        relief="flat",
        command=lambda: abrir_tickets_entrada("Genrador/ticket_entrada.py")
    ).pack(side="left", padx=20)

# Configuración de la ventana principal
ventana = tk.Tk()
ventana.title("Sistema de Gestión de Museos")

ancho_ventana = 800
alto_ventana = 600
ancho_pantalla = ventana.winfo_screenwidth()
alto_pantalla = ventana.winfo_screenheight()
pos_x = int((ancho_pantalla / 2) - (ancho_ventana / 2))
pos_y = int((alto_pantalla / 2) - (alto_ventana / 2))

ventana.geometry(f"{ancho_ventana}x{alto_ventana}+{pos_x}+{pos_y}")
ventana.config(bg="#f5f5f5")

content_frame = tk.Frame(ventana, bg="#f5f5f5")
content_frame.pack(expand=True, fill="both")

mostrar_menu_principal()
ventana.mainloop()
