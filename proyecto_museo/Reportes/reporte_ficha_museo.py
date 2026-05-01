import tkinter as tk
from tkinter import ttk, messagebox
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.colors import Color, black, HexColor
from conexion import conectar  # Tu función para conectar a la base de datos
from reportlab.pdfbase import pdfmetrics
import datetime

# === Colores personalizados ===
COLOR_ROSA = Color(226 / 255, 74 / 255, 201 / 255)
COLOR_AZUL = HexColor("#2A6FC2")
COLOR_VERDE = HexColor("#028E1C")
COLOR_ROJO = HexColor('#fc0303')
COLOR_MORADO = HexColor("#800080")

# === Función para obtener museos disponibles ===
def obtener_museos():
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

# === Función para obtener ranking de museos desde la función SQL ===
def obtener_ranking_museos():
    conn = None
    ranking = {}
    try:
        conn = conectar()
        cursor = conn.cursor()
        # Cambia "ranking_museos()" por el nombre real de la función en tu BD
        cursor.execute("SELECT nombre_museo, posicion_ranking FROM obtener_ranking_museos()")
        filas = cursor.fetchall()
    
        ranking = {nombre: pos for nombre, pos in filas}
        cursor.close()
    except Exception as e:
        messagebox.showerror("Error BD", f"Error al obtener ranking museos: {e}")
    finally:
        if conn:
            conn.close()
    return ranking

# === Función para obtener datos completos del museo ===
def obtener_datos_completos_museo(id_museo):
    conn = None
    datos = {}
    try:
        conn = conectar()
        cursor = conn.cursor()

        # Datos base + ubicación
        cursor.execute("""
            SELECT 
                m.nombre_museo,
                m.fecha_fundacion,
                m.resumen_mision,
                ciudad.nombre_lugar_geo AS ciudad,
                pais.nombre_lugar_geo AS pais,
                pais.continente
            FROM museo m
            JOIN lugar_geografico ciudad ON m.id_lugar_geo = ciudad.id_lugar_geo
            LEFT JOIN lugar_geografico pais ON ciudad.id_lugar_padre = pais.id_lugar_geo
            WHERE m.id_museo = %s;

        """, (id_museo,))
        base = cursor.fetchone()
        if base:
            datos['nombre'] = base[0]
            datos['fecha_fundacion'] = base[1]
            datos['mision'] = base[2]
            datos['ciudad'] = base[3]
            datos['pais'] = base[4] if base[4] else "N/A"
            datos['continente'] = base[5] if base[5] else "N/A"
        else:
            messagebox.showerror("Error BD", "Museo no encontrado.")
            return None

        # Resumen histórico
        cursor.execute("""
            SELECT ano, descripcion_hecho
            FROM hecho_historico
            WHERE id_museo = %s
            ORDER BY ano
        """, (id_museo,))
        datos['historico'] = cursor.fetchall()

        # Colecciones
        cursor.execute("""
            SELECT nombre_coleccion, descripcion_caracteristicas
            FROM coleccion
            WHERE id_museo = %s
            ORDER BY nombre_coleccion
        """, (id_museo,))
        datos['colecciones'] = cursor.fetchall()

        cursor.close()
    except Exception as e:
        messagebox.showerror("Error BD", f"Error al obtener datos museo: {e}")
        return None
    finally:
        if conn:
            conn.close()
    return datos

# === Función para generar PDF de la ficha del museo ===
def wrap_text(text, max_width, canvas_obj, font_name="Times-Roman", font_size=11):
    """
    Divide un texto largo en varias líneas que no excedan max_width.
    Retorna una lista de líneas.
    """
    words = text.split()
    lines = []
    current_line = ""
    for word in words:
        test_line = current_line + (" " if current_line else "") + word
        if pdfmetrics.stringWidth(test_line, font_name, font_size) <= max_width:
            current_line = test_line
        else:
            if current_line:
                lines.append(current_line)
            current_line = word
    if current_line:
        lines.append(current_line)
    return lines

def wrap_text(text, max_width, canvas_obj, font_name="Times-Roman", font_size=11):
    words = text.split()
    lines = []
    current_line = ""
    for word in words:
        test_line = current_line + (" " if current_line else "") + word
        if pdfmetrics.stringWidth(test_line, font_name, font_size) <= max_width:
            current_line = test_line
        else:
            if current_line:
                lines.append(current_line)
            current_line = word
    if current_line:
        lines.append(current_line)
    return lines

def generar_ficha_pdf(datos):
    if not datos:
        messagebox.showinfo("Sin datos", "No hay datos para generar la ficha.")
        return

    c = canvas.Canvas("ficha_museo.pdf", pagesize=LETTER)
    width, height = LETTER

    # Parámetros marco más grande
    x_marco = 30
    y_marco = 30
    ancho_marco = width - 60
    alto_marco = height - 60

    c.setStrokeColor(COLOR_ROSA)
    c.setLineWidth(3)
    c.rect(x_marco, y_marco, ancho_marco, alto_marco, stroke=1, fill=0)

    margen_interno = 15
    x_texto = x_marco + margen_interno
    y_texto = y_marco + alto_marco - margen_interno
    ancho_texto = ancho_marco - 2 * margen_interno

    # Nombre del museo en rosado centrado arriba
    font_name = "Times-Bold"
    font_size = 22
    nombre = datos['nombre']

    # Ajuste tamaño si es muy ancho
    texto_ancho = pdfmetrics.stringWidth(nombre, font_name, font_size)
    if texto_ancho > ancho_texto:
        while font_size > 14 and pdfmetrics.stringWidth(nombre, font_name, font_size) > ancho_texto:
            font_size -= 1

    # Bajar el punto de inicio del texto para dejar margen arriba
    y_texto -= 30
    
    # Fecha para ranking (hoy o la que uses)
    fecha_ranking = datetime.datetime.today().strftime('%Y-%m-%d')

    # Dibuja la fecha arriba a la derecha (por encima de posición internacional)
    c.setFont("Times-Italic", 10)
    c.setFillColor(COLOR_ROSA)
    c.drawRightString(x_marco + ancho_marco - margen_interno, y_texto + 15, f"Fecha Ranking: {fecha_ranking}")

    # Ranking arriba a la derecha, justo debajo del título
    c.setFont("Times-Bold", 12)
    c.setFillColor(COLOR_ROSA)
    ranking = obtener_ranking_museos()
    rank_str = ranking.get(datos['nombre'], "No disponible")
    c.drawRightString(x_marco + ancho_marco - margen_interno, y_texto, f"Posición Internacional: {rank_str}")

    y_texto -= 25
    
    texto_ancho = pdfmetrics.stringWidth(nombre, font_name, font_size)
    c.setFillColor(COLOR_ROSA)  # Color rosado para el nombre

    if texto_ancho > ancho_texto:
        while font_size > 14 and pdfmetrics.stringWidth(nombre, font_name, font_size) > ancho_texto:
            font_size -= 1

        if font_size == 14 and pdfmetrics.stringWidth(nombre, font_name, font_size) > ancho_texto:
            mitad = len(nombre)//2
            espacio_izq = nombre.rfind(' ', 0, mitad)
            espacio_der = nombre.find(' ', mitad)
            if espacio_izq == -1 and espacio_der == -1:
                line1 = nombre
                line2 = ""
            else:
                if espacio_izq == -1:
                    espacio = espacio_der
                elif espacio_der == -1:
                    espacio = espacio_izq
                else:
                    if mitad - espacio_izq < espacio_der - mitad:
                        espacio = espacio_izq
                    else:
                        espacio = espacio_der
                line1 = nombre[:espacio]
                line2 = nombre[espacio+1:]

            c.setFont(font_name, font_size)
            c.drawCentredString(x_marco + ancho_marco / 2, y_texto, line1)
            y_texto -= font_size + 5
            if line2:
                c.drawCentredString(x_marco + ancho_marco / 2, y_texto, line2)
            y_texto -= font_size + 20
        else:
            c.setFont(font_name, font_size)
            c.drawCentredString(x_marco + ancho_marco / 2, y_texto, nombre)
            y_texto -= font_size + 30
    else:
        c.setFont(font_name, font_size)
        c.drawCentredString(x_marco + ancho_marco / 2, y_texto, nombre)
        y_texto -= font_size + 30

    # Ahora resto del texto, con wrap automático usando wrap_text()

    c.setFont("Times-Bold", 14)
    c.setFillColor(COLOR_AZUL)
    c.drawString(x_texto, y_texto, "Datos Base:")
    y_texto -= 20

    c.setFont("Times-Roman", 12)
    c.setFillColor(black)
    c.drawString(x_texto + 20, y_texto, f"Fecha Fundación: {datos['fecha_fundacion'].strftime('%Y-%m-%d')}")
    y_texto -= 18

    # Misión con wrap
    mision_lineas = wrap_text(datos['mision'], ancho_texto - 40, c, "Times-Roman", 12)
    c.drawString(x_texto + 20, y_texto, "Misión:")
    y_texto -= 16
    for linea in mision_lineas:
        c.drawString(x_texto + 40, y_texto, linea)
        y_texto -= 14
    y_texto -= 10

    # Ubicación
    c.setFont("Times-Bold", 14)
    c.setFillColor(COLOR_VERDE)
    c.drawString(x_texto, y_texto, "Ubicación:")
    y_texto -= 20

    c.setFont("Times-Roman", 12)
    c.setFillColor(black)
    c.drawString(x_texto + 20, y_texto, f"Ciudad: {datos['ciudad']}")
    y_texto -= 18
    c.drawString(x_texto + 20, y_texto, f"País: {datos['pais']}")
    y_texto -= 18
    c.drawString(x_texto + 20, y_texto, f"Continente: {datos['continente']}")
    y_texto -= 30

    # Resumen histórico con wrap línea a línea y salto página si es necesario
    c.setFont("Times-Bold", 14)
    c.setFillColor(COLOR_MORADO)
    c.drawString(x_texto, y_texto, "Resumen Histórico:")
    y_texto -= 20

    c.setFont("Times-Roman", 11)
    c.setFillColor(black)
    if datos['historico']:
        for ano, desc in datos['historico']:
            lineas_desc = wrap_text(desc, ancho_texto - 40, c, "Times-Roman", 11)
            if y_texto < y_marco + margen_interno + 60:
                c.showPage()
                c.setStrokeColor(COLOR_ROSA)
                c.setLineWidth(3)
                c.rect(x_marco, y_marco, ancho_marco, alto_marco, stroke=1, fill=0)
                y_texto = y_marco + alto_marco - margen_interno
                c.setFont("Times-Bold", 14)
                c.setFillColor(COLOR_MORADO)
                c.drawString(x_texto, y_texto, "Resumen Histórico (cont.):")
                y_texto -= 20
                c.setFont("Times-Roman", 11)
                c.setFillColor(black)

            c.drawString(x_texto + 20, y_texto, f"{ano.year}:")
            y_texto -= 14
            for linea in lineas_desc:
                c.drawString(x_texto + 40, y_texto, linea)
                y_texto -= 14
            y_texto -= 8
    else:
        c.drawString(x_texto + 20, y_texto, "No hay hechos históricos registrados.")
        y_texto -= 30

    # Colecciones (similar)
    c.setFont("Times-Bold", 14)
    c.setFillColor(COLOR_AZUL)
    c.drawString(x_texto, y_texto, "Colecciones:")
    y_texto -= 20

    c.setFont("Times-Roman", 11)
    c.setFillColor(black)
    if datos['colecciones']:
        for nombre_col, desc_col in datos['colecciones']:
            lineas_desc_col = wrap_text(desc_col, ancho_texto - 60, c, "Times-Roman", 11)

            if y_texto < y_marco + margen_interno + 60:
                c.showPage()
                c.setStrokeColor(COLOR_ROSA)
                c.setLineWidth(3)
                c.rect(x_marco, y_marco, ancho_marco, alto_marco, stroke=1, fill=0)
                y_texto = y_marco + alto_marco - margen_interno
                c.setFont("Times-Bold", 14)
                c.setFillColor(COLOR_AZUL)
                c.drawString(x_texto, y_texto, "Colecciones (cont.):")
                y_texto -= 20
                c.setFont("Times-Roman", 11)
                c.setFillColor(black)

            c.drawString(x_texto + 20, y_texto, f"- {nombre_col}:")
            y_texto -= 14
            for linea in lineas_desc_col:
                c.drawString(x_texto + 40, y_texto, linea)
                y_texto -= 14
            y_texto -= 10
    else:
        c.drawString(x_texto + 20, y_texto, "No hay colecciones registradas.")
        y_texto -= 20

    # Pie de página
    c.setFont("Helvetica-Oblique", 10)
    c.drawString(100, 50, "© 2025 Grupo 10. Todos los derechos reservados.")

    c.save()
    messagebox.showinfo("Reporte generado", "Ficha del museo generada con éxito: ficha_museo.pdf")

# === Interfaz gráfica para generar ficha museo ===
def interfaz_ficha_museo():
    ventana = tk.Toplevel()
    ventana.title("Ficha de Museo")
    ventana.geometry("700x260")
    ventana.resizable(False, False)

    tk.Label(ventana, text="Seleccione el Museo", font=("Arial", 13, "bold")).pack(pady=12)

    museos = obtener_museos()
    if not museos:
        tk.Label(ventana, text="No hay museos disponibles en la base de datos.", fg="red").pack()
        return

    museo_var = tk.StringVar()
    combo_museos = ttk.Combobox(ventana, state="readonly", width=45, textvariable=museo_var)
    combo_museos['values'] = [f"{id_} - {nombre}" for id_, nombre in museos]
    combo_museos.current(0)
    combo_museos.pack(pady=6)

    def generar():
        seleccionado = combo_museos.get()
        if not seleccionado:
            messagebox.showwarning("Selección", "Debe seleccionar un museo.")
            return
        id_sel = int(seleccionado.split(" - ")[0])
        datos = obtener_datos_completos_museo(id_sel)
        if datos:
            generar_ficha_pdf(datos)

    tk.Button(ventana, text="Generar Reporte", command=generar,
        bg="#C816DC", fg="white", font=("Arial", 11, "bold"),
        width=20, height=2).pack(pady=15)
