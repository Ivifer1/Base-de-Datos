import tkinter as tk
from tkinter import ttk, messagebox
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.colors import Color, black, HexColor
import psycopg2
from conexion import conectar

def obtener_museos():
    """Obtiene la lista de museos desde la base de datos."""
    conn = None
    museos = []
    try:
        conn = conectar()
        cursor = conn.cursor()
        cursor.execute("SELECT id_museo, nombre_museo FROM museo ORDER BY id_museo")
        museos = cursor.fetchall()
        cursor.close()
    except Exception as e:
        messagebox.showerror("Error BD", f"Error al obtener museos: {e}")
    finally:
        if conn:
            conn.close()
    return museos

def obtener_estructura_organizacional(id_museo):
    """Obtiene la estructura organizacional (nombre, tipo, nivel) de un museo."""
    conn = None
    estructura = []
    try:
        conn = conectar()
        cursor = conn.cursor()
        query = """
            SELECT nombre_est_or, tipo_est_org, nivel
            FROM estructura_organizacional
            WHERE id_museo = %s
            ORDER BY nivel, nombre_est_or;
        """
        cursor.execute(query, (id_museo,))
        estructura = cursor.fetchall()
        cursor.close()
    except Exception as e:
        messagebox.showerror("Error BD", f"Error al obtener estructura organizacional: {e}")
    finally:
        if conn:
            conn.close()
    return estructura

def generar_reporte_estructura_organizacional(nombre_museo, estructura_org):
    from collections import defaultdict
    from reportlab.pdfgen import canvas
    from reportlab.lib.pagesizes import LETTER
    from reportlab.lib.colors import Color, black, HexColor

    if not estructura_org:
        messagebox.showinfo("Sin datos", "No hay estructura organizacional para este museo.")
        return

    # Agrupamos por nivel y tipo
    niveles = defaultdict(lambda: {"dire": [], "depa": [], "secc": []})
    for nombre, tipo, nivel in estructura_org:
        if tipo in ['dire', 'depa', 'secc']:
            niveles[nivel][tipo].append(nombre)

    c = canvas.Canvas("estructura_organizacional.pdf", pagesize=LETTER)
    width, height = LETTER
    margen = 20

    # Colores definidos
    color_rosa = Color(226 / 255, 74 / 255, 201 / 255)
    color_azul = HexColor('#2A6FC2')     # Para Nivel 1 y Dirección
    color_verde = HexColor('#028E1C')    # Para Nivel 2 y Departamentos
    color_morado = HexColor("#800080")   # Para Nivel 3 y Secciones

    c.setStrokeColor(color_rosa)
    c.setLineWidth(3)
    c.rect(margen, margen, width - 2 * margen, height - 2 * margen, stroke=1, fill=0)

    # Título principal
    c.setFont("Times-Bold", 20)
    c.setFillColor(color_rosa)
    titulo_width = c.stringWidth(nombre_museo, "Times-Bold", 20)
    c.drawString((width - titulo_width) / 2, height - 60, nombre_museo)

    y = height - 100
    c.setFont("Times-Bold", 14)
    c.setFillColor(black)
    c.drawString(margen + 20, y, "Estructura Organizacional:")
    y -= 25

    c.setFont("Times-Roman", 12)

    for nivel in sorted(niveles.keys()):
        if y < 100:
            c.showPage()
            c.setStrokeColor(color_rosa)
            c.setLineWidth(3)
            c.rect(margen, margen, width - 2 * margen, height - 2 * margen, stroke=1, fill=0)
            c.setFont("Times-Bold", 20)
            c.setFillColor(color_rosa)
            c.drawString((width - titulo_width) / 2, height - 60, nombre_museo)
            y = height - 100
            c.setFont("Times-Bold", 14)
            c.setFillColor(black)
            c.drawString(margen + 20, y, "Estructura Organizacional:")
            y -= 25
            c.setFont("Times-Roman", 12)

        # Selección de color por nivel
        if nivel == 1:
            color_nivel = color_azul
        elif nivel == 2:
            color_nivel = color_verde
        elif nivel == 3:
            color_nivel = color_morado
        else:
            color_nivel = black

        # Nivel
        c.setFont("Times-Bold", 12)
        c.setFillColor(color_nivel)
        c.drawString(margen + 30, y, f"Nivel {nivel}:")
        y -= 18

        # Dirección
        direcciones = niveles[nivel]['dire']
        if direcciones:
            c.setFont("Times-Italic", 11)
            c.setFillColor(color_azul)
            c.drawString(margen + 50, y, "Dirección:")
            y -= 16
            c.setFont("Times-Roman", 12)
            c.setFillColor(black)
            for dire in direcciones:
                c.drawString(margen + 70, y, f"- {dire}")
                y -= 15

        # Departamentos
        departamentos = niveles[nivel]['depa']
        if departamentos:
            c.setFont("Times-Italic", 11)
            c.setFillColor(color_verde)
            c.drawString(margen + 50, y, "Departamentos:")
            y -= 16
            c.setFont("Times-Roman", 12)
            c.setFillColor(black)
            for depa in departamentos:
                c.drawString(margen + 70, y, f"- {depa}")
                y -= 15

        # Secciones
        secciones = niveles[nivel]['secc']
        if secciones:
            c.setFont("Times-Italic", 11)
            c.setFillColor(color_morado)
            c.drawString(margen + 50, y, "Secciones:")
            y -= 16
            c.setFont("Times-Roman", 12)
            c.setFillColor(black)
            for secc in secciones:
                c.drawString(margen + 70, y, f"- {secc}")
                y -= 15

        y -= 10  # Espacio entre niveles

    # Pie de página
    c.setFont("Helvetica-Oblique", 10)
    c.setFillColor(black)
    c.drawString(100, 50, "© 2025 Grupo 10. Todos los derechos reservados.")

    c.save()
    messagebox.showinfo("Reporte generado", "Reporte generado con éxito: estructura_organizacional.pdf")

def interfaz_estructura_organizacional():
    ventana = tk.Toplevel()
    ventana.title("Reporte Estructura Organizacional")
    ventana.geometry("700x220")
    ventana.resizable(False, False)

    tk.Label(ventana, text="Seleccione el Museo:", font=("Arial", 12, "bold")).pack(pady=10)

    museos = obtener_museos()
    if not museos:
        tk.Label(ventana, text="No hay museos disponibles.", fg="red").pack()
        return

    museo_var = tk.StringVar()
    # Solo nombres, sin ID en el texto visible
    nombres_museos = [m[1] for m in museos]
    combo_museos = ttk.Combobox(ventana, textvariable=museo_var, state="readonly", width=50, font=("Arial", 10))
    combo_museos['values'] = nombres_museos
    combo_museos.pack(pady=5)

    def generar():
        seleccion = combo_museos.current()
        if seleccion == -1:
            messagebox.showwarning("Atención", "Debe seleccionar un museo")
            return

        id_museo = museos[seleccion][0]
        nombre_museo = museos[seleccion][1]
        estructura = obtener_estructura_organizacional(id_museo)
        generar_reporte_estructura_organizacional(nombre_museo, estructura)

    btn_generar = tk.Button(ventana, text="Generar Reporte", command=generar, bg="#C816DC", fg="white", font=("Arial", 11, "bold"))
    btn_generar.pack(pady=20)

    ventana.mainloop()