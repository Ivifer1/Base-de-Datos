import tkinter as tk
from tkinter import ttk, messagebox
import sys
import os
from reportlab.lib.pagesizes import LETTER
from reportlab.pdfgen import canvas
from conexion import conectar

# Permitir acceso a App.py
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

def safe_str(text):
    if text is None:
        return ""
    if isinstance(text, bytes):
        return text.decode('utf-8')
    return str(text)

def generar_pdf_ficha_empleado(empleado, nombre_museo=None, departamento=None):
    try:
        nombre_archivo = f"ficha_empleado_{empleado['id']}.pdf"
        c = canvas.Canvas(nombre_archivo, pagesize=LETTER)

        color_rosado = (226/255, 74/255, 201/255)
        c.setStrokeColorRGB(*color_rosado)
        c.setLineWidth(3)
        margen = 20
        ancho_pagina, alto_pagina = LETTER
        c.rect(margen, margen, ancho_pagina - 2*margen, alto_pagina - 2*margen, stroke=1, fill=0)

        c.setFont("Times-Roman", 12)

        if nombre_museo:
            c.setFont("Times-Bold", 20)
            c.setFillColorRGB(*color_rosado)
            texto_museo = f"{nombre_museo}"
            ancho_texto = c.stringWidth(texto_museo, "Times-Bold", 20)
            x = (ancho_pagina - ancho_texto) / 2
            c.drawString(x, 720, texto_museo)

        if departamento:
            c.setFont("Times-Italic", 14)
            c.setFillColorRGB(0, 0, 0)
            ancho_depto = c.stringWidth(departamento, "Times-Italic", 14)
            x_depto = (ancho_pagina - ancho_depto) / 2
            c.drawString(x_depto, 700, departamento)

        c.setFont("Times-Bold", 12)
        c.setFillColorRGB(0, 0, 0)
        c.drawString(100, 680, "Datos personales:")
        y = 650
        titulo_font = "Times-Bold"
        valor_font = "Times-Roman"
        font_size = 12

        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Nombre:")
        c.setFont(valor_font, font_size)
        c.drawString(160, y, safe_str(empleado['nombre']))

        y -= 20
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Cédula:")
        c.setFont(valor_font, font_size)
        c.drawString(160, y, safe_str(empleado['doc_identidad']))

        y -= 20
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Correo:")
        c.setFont(valor_font, font_size)
        c.drawString(160, y, safe_str(empleado['correo']))

        y -= 20
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Teléfono:")
        c.setFont(valor_font, font_size)
        c.drawString(160, y, safe_str(empleado['telefono']))

        y -= 20
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Fecha de nacimiento:")
        c.setFont(valor_font, font_size)
        c.drawString(220, y, safe_str(empleado['fecha_nacimiento']))

        y -= 20
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Género:")
        c.setFont(valor_font, font_size)
        c.drawString(160, y, safe_str(empleado['genero']))

        # Idiomas
        y -= 30
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Idiomas hablados:")
        c.setFont(valor_font, font_size)
        for idioma in empleado['idiomas']:
            y -= 15
            c.drawString(120, y, f"- {safe_str(idioma)}")

        # Título y especialidad
        y -= 25
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Título:")
        c.setFont(valor_font, font_size)
        c.drawString(160, y, safe_str(empleado['titulo']))

        y -= 20
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Especialidad:")
        c.setFont(valor_font, font_size)
        c.drawString(180, y, safe_str(empleado['especializacion']))

        # Historial laboral
        y -= 30
        c.setFont(titulo_font, font_size)
        c.drawString(100, y, "Historial laboral:")
        c.setFont(valor_font, font_size)
        for entry in empleado['historial']:
            y -= 15
            texto_hist = f"{safe_str(entry['cargo'])} - {safe_str(entry['fecha_inicio'])} a {safe_str(entry['fecha_fin'])}"
            c.drawString(120, y, texto_hist)

        c.setFont("Helvetica-Oblique", 10)
        c.drawString(100, 50, "© 2025 Grupo 10. Todos los derechos reservados.")

        c.save()
        messagebox.showinfo("Éxito", f"PDF generado: {nombre_archivo}")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo generar el PDF:\n{e}")

def interfaz_reporte_ficha_empleado():
    ventana = tk.Toplevel()
    ventana.title("Ficha de Empleado")
    ventana.geometry("700x300")

    tk.Label(ventana, text="Seleccione un museo:", font=("Arial", 13, "bold")).pack(pady=5)
    combo_museos = ttk.Combobox(ventana, state="readonly", width=50, font=("Arial", 10))
    combo_museos.pack()

    tk.Label(ventana, text="Seleccione un cargo:" , font=("Arial", 13, "bold")).pack(pady=5)
    combo_cargos = ttk.Combobox(ventana, state="readonly", values=["Curador", "Restaurador"], width=50, font=("Arial", 10,))
    combo_cargos.pack()

    tk.Label(ventana, text="Seleccione un empleado:" , font=("Arial", 13, "bold")).pack(pady=5)
    combo_empleados = ttk.Combobox(ventana, state="readonly", width=50, font=("Arial", 10))
    combo_empleados.pack()

    empleados_actuales = []

    def cargar_museos():
        conn = conectar()
        if not conn:
            return
        cur = conn.cursor()
        cur.execute("SELECT id_museo, nombre_museo FROM museo ORDER BY id_museo")
        museos = cur.fetchall()
        conn.close()
        combo_museos["values"] = [m[1] for m in museos]
        combo_museos.museos_data = {m[1]: m[0] for m in museos}

    def cargar_empleados(*args):
        museo = combo_museos.get()
        cargo = combo_cargos.get()
        if museo not in combo_museos.museos_data or not cargo:
            return

        id_museo = combo_museos.museos_data[museo]

        conn = conectar()
        if not conn:
            return
        cur = conn.cursor()
        cur.execute("""
            SELECT DISTINCT ep.id_emp_pro, ep.primer_nombre, ep.segundo_nombre, ep.primer_apellido, ep.segundo_apellido,
            ep.doc_identidad, ep.correo, ep.telefono, ep.fecha_nacimiento, ep.genero
            FROM empleado_profesional ep
            JOIN historico_empleado he ON ep.id_emp_pro = he.id_emp_pro
            WHERE ep.id_museo = %s AND he.cargo = %s
        """, (id_museo, cargo))

        empleados = cur.fetchall()
        conn.close()

        empleados_actuales.clear()
        combo_empleados["values"] = []

        nombres_empleados = []
        for emp in empleados:
            nombre = f"{emp[1]} {emp[2] or ''} {emp[3]} {emp[4]}"
            nombres_empleados.append(nombre)
            empleados_actuales.append({
                "id": emp[0],
                "nombre": nombre,
                "doc_identidad": emp[5],
                "correo": emp[6],
                "telefono": emp[7],
                "fecha_nacimiento": str(emp[8]),
                "genero": emp[9]
            })

        combo_empleados["values"] = nombres_empleados

    def generar():
        index = combo_empleados.current()
        if index == -1:
            messagebox.showwarning("Advertencia", "Debe seleccionar un empleado.")
            return

        museo = combo_museos.get()
        empleado = empleados_actuales[index]
        id_emp = empleado["id"]

        conn = conectar()
        if not conn:
            return
        cur = conn.cursor()

        # Idiomas
        cur.execute("""
            SELECT i.nom_idioma
            FROM idioma_hablado ih
            JOIN idioma i ON ih.id_idioma = i.id_idioma
            WHERE ih.id_emp_pro = %s
        """, (id_emp,))
        empleado["idiomas"] = [row[0] for row in cur.fetchall()]

        # Título
        cur.execute("""
            SELECT nombre_titulo, especializacion
            FROM titulo_formacion
            WHERE id_emp_pro = %s
        """, (id_emp,))
        row = cur.fetchone()
        if row:
            empleado["titulo"] = row[0]
            empleado["especializacion"] = row[1]
        else:
            empleado["titulo"] = "No registrado"
            empleado["especializacion"] = "No registrada"

        # Historial laboral
        cur.execute("""
            SELECT cargo, fecha_inicio, fecha_fin
            FROM historico_empleado
            WHERE id_emp_pro = %s ORDER BY fecha_inicio
        """, (id_emp,))
        empleado["historial"] = [{
            "cargo": r[0],
            "fecha_inicio": str(r[1]),
            "fecha_fin": str(r[2]) if r[2] else "Actual"
        } for r in cur.fetchall()]

        # Departamento (tipo 'depa') actual
        cur.execute("""
            SELECT eo.nombre_est_or
            FROM historico_empleado he
            JOIN estructura_organizacional eo 
            ON he.id_est_org = eo.id_est_org AND he.id_museo = eo.id_museo
            WHERE he.id_emp_pro = %s
            AND eo.tipo_est_org = 'depa'
            ORDER BY he.fecha_inicio DESC
            LIMIT 1
        """, (id_emp,))
        departamento = cur.fetchone()
        departamento_nombre = departamento[0] if departamento else ""

        conn.close()

        print(f"Generando PDF para empleado: {empleado['nombre']} ({empleado['id']})")
        generar_pdf_ficha_empleado(empleado, nombre_museo=museo, departamento=departamento_nombre)

    combo_museos.bind("<<ComboboxSelected>>", cargar_empleados)
    combo_cargos.bind("<<ComboboxSelected>>", cargar_empleados)

    tk.Button(
        ventana,
        text="Generar PDF",
        command=generar,
        bg="#C816DC",
        fg="white",
        font=("Arial", 12),
        relief="flat",
        padx=10, pady=5
    ).pack(pady=30)

    cargar_museos()
