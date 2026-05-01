import tkinter as tk
from tkinter import ttk, messagebox
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.colors import Color, black, HexColor
from conexion import conectar # Assuming 'conexion.py' contains your database connection logic

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

# === Función para obtener pisos/plantas disponibles para un museo ===
def obtener_pisos_museo(id_museo):
    conn = None
    pisos = []
    try:
        conn = conectar()
        cursor = conn.cursor()
        cursor.execute("SELECT nombre_est FROM estructura_fisica WHERE id_museo = %s AND tipo_est = 'piso_planta' ORDER BY nombre_est", (id_museo,))
        pisos = [row[0] for row in cursor.fetchall()]
        cursor.close()
    except Exception as e:
        messagebox.showerror("Error BD", f"Error al obtener pisos: {e}")
    finally:
        if conn:
            conn.close()
    return pisos

# === Función para obtener estructura física completa o filtrada por piso del museo ===
def obtener_estructura_completa(id_museo, floor_name=None):
    conn = None
    datos = []
    try:
        conn = conectar()
        cursor = conn.cursor()
        if floor_name:
            # First, find the id of the floor
            cursor.execute("SELECT id_est_fisica FROM estructura_fisica WHERE id_museo = %s AND nombre_est = %s AND tipo_est = 'piso_planta'", (id_museo, floor_name))
            floor_id_row = cursor.fetchone()
            if not floor_id_row:
                messagebox.showwarning("Piso no encontrado", f"El piso '{floor_name}' no se encontró para el museo seleccionado.")
                return []
            floor_id = floor_id_row[0]

            query = """
                WITH RECURSIVE Hierarchy AS (
                    SELECT
                        ef.id_est_fisica,
                        ef.nombre_est,
                        ef.tipo_est,
                        ef.descripcion_est,
                        ef.direccion_edificio,
                        ef.id_est_padre,
                        ef.id_museo, -- ADDED: Include id_museo in the initial SELECT
                        se.id_sala_exp,
                        se.nombre_sala_expo,
                        se.descripcion AS desc_sala,
                        c.id_coleccion,
                        c.nombre_coleccion,
                        sc.orden_recorrido
                    FROM estructura_fisica ef
                    LEFT JOIN sala_exp se ON ef.id_est_fisica = se.id_est_fisica AND ef.id_museo = se.id_museo
                    LEFT JOIN sala_col sc ON se.id_sala_exp = sc.id_sala_exp AND se.id_est_fisica = sc.id_est_fisica AND se.id_museo = sc.id_museo
                    LEFT JOIN coleccion c ON sc.id_coleccion = c.id_coleccion AND sc.id_est_org = c.id_est_org AND sc.id_museo = c.id_museo
                    WHERE ef.id_est_fisica = %s AND ef.id_museo = %s

                    UNION ALL

                    SELECT
                        ef_child.id_est_fisica,
                        ef_child.nombre_est,
                        ef_child.tipo_est,
                        ef_child.descripcion_est,
                        ef_child.direccion_edificio,
                        ef_child.id_est_padre,
                        ef_child.id_museo, -- ADDED: Include id_museo in the recursive SELECT
                        se_child.id_sala_exp,
                        se_child.nombre_sala_expo,
                        se_child.descripcion AS desc_sala_child,
                        c_child.id_coleccion,
                        c_child.nombre_coleccion,
                        sc_child.orden_recorrido
                    FROM estructura_fisica ef_child
                    INNER JOIN Hierarchy h ON ef_child.id_est_padre = h.id_est_fisica AND ef_child.id_museo = h.id_museo
                    LEFT JOIN sala_exp se_child ON ef_child.id_est_fisica = se_child.id_est_fisica AND ef_child.id_museo = se_child.id_museo
                    LEFT JOIN sala_col sc_child ON se_child.id_sala_exp = sc_child.id_sala_exp AND se_child.id_est_fisica = sc_child.id_est_fisica AND se_child.id_museo = sc_child.id_museo
                    LEFT JOIN coleccion c_child ON sc_child.id_coleccion = c_child.id_coleccion AND sc_child.id_est_org = c_child.id_est_org AND sc_child.id_museo = c_child.id_museo
                )
                SELECT DISTINCT
                    id_est_fisica, nombre_est, tipo_est, descripcion_est, direccion_edificio, id_est_padre,
                    id_sala_exp, nombre_sala_expo, desc_sala, id_coleccion, nombre_coleccion, orden_recorrido
                FROM Hierarchy ORDER BY id_est_padre NULLS FIRST, id_est_fisica, id_sala_exp, orden_recorrido;
            """
            cursor.execute(query, (floor_id, id_museo))

        else:
            # Original query for full structure
            query = """
                SELECT ef.id_est_fisica, ef.nombre_est, ef.tipo_est, ef.descripcion_est, ef.direccion_edificio, ef.id_est_padre,
                        se.id_sala_exp, se.nombre_sala_expo, se.descripcion,
                        c.id_coleccion, c.nombre_coleccion, sc.orden_recorrido
                FROM estructura_fisica ef
                LEFT JOIN sala_exp se ON ef.id_est_fisica = se.id_est_fisica AND ef.id_museo = se.id_museo
                LEFT JOIN sala_col sc ON se.id_sala_exp = sc.id_sala_exp AND se.id_est_fisica = sc.id_est_fisica AND se.id_museo = sc.id_museo
                LEFT JOIN coleccion c ON sc.id_coleccion = c.id_coleccion AND sc.id_est_org = c.id_est_org AND sc.id_museo = c.id_museo
                WHERE ef.id_museo = %s
                ORDER BY ef.id_est_padre NULLS FIRST, ef.id_est_fisica, se.id_sala_exp, sc.orden_recorrido;
            """
            cursor.execute(query, (id_museo,))
        datos = cursor.fetchall()
        cursor.close()
    except Exception as e:
        messagebox.showerror("Error BD", f"Error al obtener estructura: {e}")
    finally:
        if conn:
            conn.close()
    return datos

# === Función principal para generar el PDF ===
def generar_reporte_estructura_fisica(nombre_museo, estructura, floor_name=None):
    if not estructura:
        messagebox.showinfo("Sin datos", "No hay estructura para este museo o piso.")
        return

    file_name = f"estructura_fisica_{nombre_museo.replace(' ', '_')}"
    if floor_name:
        file_name += f"_{floor_name.replace(' ', '_')}"
    file_name += ".pdf"

    c = canvas.Canvas(file_name, pagesize=LETTER)
    width, height = LETTER
    margen = 20
    margen_texto = margen + 30

    # Marco y título
    c.setStrokeColor(COLOR_ROSA)
    c.setLineWidth(3)
    c.rect(margen, margen, width - 2 * margen, height - 2 * margen, stroke=1, fill=0)

    c.setFont("Times-Bold", 20)
    c.setFillColor(COLOR_ROSA)
    report_title = nombre_museo
    if floor_name:
        report_title += f" - Piso: {floor_name}"
    titulo_width = c.stringWidth(report_title, "Times-Bold", 20)
    c.drawString((width - titulo_width) / 2, height - 60, report_title)

    y = height - 100
    c.setFont("Times-Bold", 14)
    c.setFillColor(black)
    c.drawString(margen_texto, y, "Estructura Física:")
    y -= 25

    # Organizar datos
    hijos, nodos, salas, colecciones = {}, {}, {}, {}
    # Find the root elements for the current report (could be museum or the selected floor)

    for fila in estructura:
        # The recursive CTE returns 12 columns, consistent with previous queries.
        # id_museo is used internally in the CTE for filtering but not returned in the final SELECT DISTINCT.
        id_est, nombre, tipo, desc, direccion, id_padre, id_sala, nombre_sala, desc_sala, id_col, nombre_col, orden = fila
        if id_est not in nodos:
            nodos[id_est] = (nombre, tipo, desc, direccion, id_padre)
            # For the filtered report, the selected floor becomes a "root"
            if floor_name and tipo.lower() == 'piso_planta' and nombre == floor_name:
                hijos.setdefault(None, []).append(id_est) # Treat the floor as a top-level item for this report
            elif not floor_name and id_padre is None: # Original logic for full report
                hijos.setdefault(None, []).append(id_est)
            elif id_padre is not None:
                hijos.setdefault(id_padre, []).append(id_est)

        if id_sala:
            salas.setdefault(id_est, {})[id_sala] = (nombre_sala, desc_sala)
        if id_col:
            colecciones.setdefault((id_est, id_sala), []).append((orden, nombre_col))

    # Sort children for consistent output
    for parent_id in hijos:
        if hijos[parent_id]:
            hijos[parent_id].sort(key=lambda x: nodos[x][0]) # Sort by name

    # Dibuja recursivamente
    def dibujar_nivel(id_padre, nivel, y_actual):
        indent = 20 * nivel
        if id_padre not in hijos:
            return y_actual

        for hijo in hijos[id_padre]:
            nombre, tipo, descripcion, direccion, _ = nodos[hijo]

            # Check for new page before drawing
            required_height = 18 # for name
            if descripcion: required_height += 14
            if direccion: required_height += 14
            if hijo in salas:
                for id_sala_temp, (nombre_sala_temp, desc_sala_temp) in salas[hijo].items():
                    required_height += 16
                    if desc_sala_temp: required_height += 14
                    if (hijo, id_sala_temp) in colecciones:
                        required_height += len(colecciones[(hijo, id_sala_temp)]) * 14
                    required_height += 8
            # Add some buffer
            required_height += 10

            if y_actual - required_height < 70: # Check if enough space is left for the current entry + buffer
                c.showPage()
                c.setStrokeColor(COLOR_ROSA)
                c.setLineWidth(3)
                c.rect(margen, margen, width - 2 * margen, height - 2 * margen, stroke=1, fill=0)
                c.setFont("Times-Bold", 20)
                c.setFillColor(COLOR_ROSA)
                c.drawString((width - titulo_width) / 2, height - 60, report_title) # Use updated report_title
                y_actual = height - 100
                c.setFont("Times-Bold", 14)
                c.setFillColor(black)
                c.drawString(margen_texto, y_actual, "Estructura Física:")
                y_actual -= 25


            # Texto principal (siempre tamaño 12)
            c.setFont("Times-Roman", 12)
            tipo_limpio = tipo.lower()
            color_texto = black # Default color

            if tipo_limpio == "edi":
                color_texto = COLOR_ROJO
            elif tipo_limpio == "piso_planta":
                color_texto = COLOR_AZUL
            elif tipo_limpio == "area_seccion":
                color_texto = COLOR_MORADO

            c.setFillColor(color_texto)
            c.drawString(margen_texto + indent, y_actual, f"- {nombre} ({tipo})") # Added type for clarity
            y_actual -= 18
            c.setFillColor(black)

            # Descripción y dirección
            if descripcion:
                c.setFont("Times-Italic", 10)
                c.drawString(margen_texto + indent + 15, y_actual, f"{descripcion}")
                y_actual -= 14
            if direccion:
                c.setFont("Times-Italic", 10)
                c.drawString(margen_texto + indent + 15, y_actual, f"Dirección: {direccion}")
                y_actual -= 14

            # Salas y colecciones
            if hijo in salas:
                for id_sala, (nombre_sala, desc_sala) in salas[hijo].items():
                    c.setFont("Times-Roman", 12)
                    c.setFillColor(COLOR_VERDE)
                    c.drawString(margen_texto + indent + 20, y_actual, f"→ Sala: {nombre_sala}")
                    y_actual -= 16
                    c.setFillColor(black)
                    if desc_sala:
                        c.setFont("Times-Italic", 10)
                        c.drawString(margen_texto + indent + 35, y_actual, f"Descripción de la sala: {desc_sala}")
                        y_actual -= 14
                    if (hijo, id_sala) in colecciones:
                        c.setFont("Times-Roman", 10)
                        # Sort collections by order
                        for orden, nombre_col in sorted(colecciones[(hijo, id_sala)]):
                            c.drawString(margen_texto + indent + 35, y_actual, f"Colección: {nombre_col}") # Added order for clarity
                            y_actual -= 14
                    y_actual -= 8

            y_actual = dibujar_nivel(hijo, nivel + 1, y_actual)
            y_actual -= 5
        return y_actual

    # Start drawing from the appropriate root(s)
    y = dibujar_nivel(None, 0, y)

    # Pie de página
    c.setFont("Helvetica-Oblique", 10)
    c.drawString(100, 50, "© 2025 Grupo 10. Todos los derechos reservados.")
    c.save()

    messagebox.showinfo("Reporte generado", f"Reporte generado con éxito: {file_name}")

# === Interfaz gráfica con tkinter ===
def interfaz_estructura_fisica():
    ventana = tk.Toplevel()
    ventana.title("Reporte de Estructura Física")
    ventana.geometry("700x280") # Adjusted height
    ventana.resizable(False, False)

    tk.Label(ventana, text="Seleccione el Museo", font=("Arial", 13, "bold")).pack(pady=12)

    museos = obtener_museos()
    if not museos:
        tk.Label(ventana, text="No hay museos disponibles en la base de datos.", fg="red").pack()
        return

    museo_var = tk.StringVar()
    combo_museos = ttk.Combobox(ventana, textvariable=museo_var, state="readonly", width=60, font=("Arial", 11))
    combo_museos['values'] = [m[1] for m in museos]
    combo_museos.pack(pady=8)

    tk.Label(ventana, text="Filtro Opcional por Piso/Planta:", font=("Arial", 11)).pack(pady=5)
    piso_var = tk.StringVar()
    combo_pisos = ttk.Combobox(ventana, textvariable=piso_var, state="readonly", width=60, font=("Arial", 11))
    combo_pisos.pack(pady=5)

    # Function to update available floors when a museum is selected
    def on_museo_selected(event):
        idx = combo_museos.current()
        if idx != -1:
            id_museo = museos[idx][0]
            pisos = obtener_pisos_museo(id_museo)
            # Add an empty option to allow selecting no filter
            combo_pisos['values'] = [''] + pisos # Add empty string for "no filter"
            combo_pisos.set('') # Clear current floor selection
        else:
            combo_pisos['values'] = ['']
            combo_pisos.set('')

    combo_museos.bind("<<ComboboxSelected>>", on_museo_selected)

    def generar():
        idx = combo_museos.current()
        if idx == -1:
            messagebox.showwarning("Atención", "Debe seleccionar un museo.")
            return

        id_museo = museos[idx][0]
        nombre_museo = museos[idx][1]
        floor_name = piso_var.get().strip() # Get floor name from combobox

        # If floor_name is empty, it means no filter is applied, so pass None
        if not floor_name:
            floor_name = None

        estructura = obtener_estructura_completa(id_museo, floor_name)
        generar_reporte_estructura_fisica(nombre_museo, estructura, floor_name)

    tk.Button(ventana, text="Generar Reporte", command=generar,
              bg="#C816DC", fg="white", font=("Arial", 11, "bold"),
              width=20, height=2).pack(pady=15)

    ventana.mainloop()

# To run this, you would typically call:
# if __name__ == "__main__":
#     interfaz_estructura_fisica()