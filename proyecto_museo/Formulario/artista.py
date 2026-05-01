# form_artista.py
import tkinter as tk
from tkinter import ttk, messagebox
from conexion import conectar
from datetime import datetime


def limpiar_frame(frame):
    for widget in frame.winfo_children():
        widget.destroy()


def mostrar_formulario_artista(content_frame, volver_callback=None):
    limpiar_frame(content_frame)

    tk.Label(
        content_frame,
        text="Registro de Artista",
        font=("Arial", 18, "bold"),
        bg="#f5f5f5",
        fg="#333"
    ).pack(pady=10)

    frame = ttk.LabelFrame(content_frame, text="Datos del Artista", padding=15)
    frame.pack(padx=20, pady=10, fill="both", expand=True)

    campos = {}
    row_idx = 0

    # === Campos de texto ===
    etiquetas = [
        ("Resumen características artísticas *:", 'resumen_carac_art'),
        ("Nombre artístico:", 'nombre_artistico'),
        ("Nombre:", 'nombre_artista'),
        ("Apellido:", 'apellido'),
        ("Fecha nacimiento (YYYY-MM-DD):", 'fecha_nacimiento_artista'),
        ("Fecha muerte (opcional):", 'fecha_muerte_artista'),
        ("País de nacimiento (opcional):", 'pais'),
        ("Continente (opcional):", 'continente'),
    ]

    for label_text, key in etiquetas:
        ttk.Label(frame, text=label_text).grid(row=row_idx, column=0, sticky="w", pady=5)
        entry = ttk.Entry(frame, width=40)
        entry.grid(row=row_idx, column=1, padx=10, pady=5)
        campos[key] = entry
        row_idx += 1

    # === Selección de obras ===
    ttk.Label(frame, text="Obras asociadas (Ctrl+clic para varias):").grid(row=row_idx, column=0, sticky="nw", pady=5)
    listbox_obras = tk.Listbox(frame, selectmode="multiple", height=10, width=50, exportselection=False)
    listbox_obras.grid(row=row_idx, column=1, padx=10, pady=5, sticky="w")
    campos['listbox_obras'] = listbox_obras
    row_idx += 1

    try:
        conn = conectar()
        cur = conn.cursor()
        cur.execute("SELECT id_obra, nom_obra FROM obra ORDER BY nom_obra")
        obras = cur.fetchall()
        obra_dict = {titulo: id_ for id_, titulo in obras}
        campos['obra_dict'] = obra_dict

        for titulo in obra_dict:
            listbox_obras.insert(tk.END, titulo)

        conn.close()
    except Exception as e:
        messagebox.showerror("Error", f"No se pudieron cargar las obras:\n{e}")

    def limpiar_campos():
        for entry in campos.values():
            if isinstance(entry, ttk.Entry):
                entry.delete(0, tk.END)
        campos['listbox_obras'].selection_clear(0, tk.END)

    def guardar_artista():
        resumen = campos['resumen_carac_art'].get().strip()
        if not resumen:
            messagebox.showwarning("Campo obligatorio", "El resumen es obligatorio.")
            return

        nombre_artistico = campos['nombre_artistico'].get().strip() or None
        nombre = campos['nombre_artista'].get().strip() or None
        apellido = campos['apellido'].get().strip() or None
        fecha_nac_str = campos['fecha_nacimiento_artista'].get().strip()
        fecha_muerte_str = campos['fecha_muerte_artista'].get().strip()
        pais = campos['pais'].get().strip() or None
        continente = campos['continente'].get().strip() or None

        obras_seleccionadas_idx = campos['listbox_obras'].curselection()
        if not obras_seleccionadas_idx:
            messagebox.showwarning("Campo obligatorio", "Debe seleccionar al menos una obra.")
            return
        obras_seleccionadas = [
            campos['obra_dict'][campos['listbox_obras'].get(i)]
            for i in obras_seleccionadas_idx
        ]

        try:
            fecha_nac = datetime.strptime(fecha_nac_str, "%Y-%m-%d").date() if fecha_nac_str else None
            fecha_muerte = datetime.strptime(fecha_muerte_str, "%Y-%m-%d").date() if fecha_muerte_str else None
        except ValueError:
            messagebox.showerror("Error", "Formato de fecha inválido. Use YYYY-MM-DD")
            return

        conn = None
        try:
            conn = conectar()
            cur = conn.cursor()

            id_lugar_geo = None
            if pais:
                cur.execute("""
                    SELECT id_lugar_geo FROM lugar_geografico
                    WHERE unaccent(upper(nombre_lugar_geo)) = unaccent(upper(%s))
                    AND tipo_lugar = 'p'
                    LIMIT 1
                """, (pais,))
                resultado = cur.fetchone()

                if resultado:
                    id_lugar_geo = resultado[0]
                else:
                    cur.execute("""
                        INSERT INTO lugar_geografico (nombre_lugar_geo, tipo_lugar, continente)
                        VALUES (%s, 'p', %s)
                        RETURNING id_lugar_geo
                    """, (pais, continente))
                    id_lugar_geo = cur.fetchone()[0]

            # Insertar artista
            cur.execute("""
                INSERT INTO artista (
                    resumen_carac_art, nombre_artistico, nombre_artista, apellido,
                    fecha_nacimiento_artista, fecha_muerte_artista, id_lugar_geo
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                RETURNING id_artista
            """, (
                resumen, nombre_artistico, nombre, apellido,
                fecha_nac, fecha_muerte, id_lugar_geo
            ))
            id_artista = cur.fetchone()[0]

            # Insertar relación en autor
            for id_obra in obras_seleccionadas:
                cur.execute("""
                    INSERT INTO autor (id_artista, id_obra)
                    VALUES (%s, %s)
                """, (id_artista, id_obra))

            conn.commit()
            messagebox.showinfo("Éxito", "Artista y obras asociadas registradas correctamente.")
            limpiar_campos()

        except Exception as e:
            if conn:
                conn.rollback()
            messagebox.showerror("Error", f"No se pudo registrar el artista:\n{e}")
        finally:
            if conn:
                conn.close()

    # Botón
    button_frame = ttk.Frame(content_frame, padding=10)
    button_frame.pack(pady=10)
    ttk.Button(button_frame, text="Guardar Artista", command=guardar_artista).pack(side="left", padx=10)


# ==== Prueba independiente ====
if __name__ == "__main__":
    def volver():
        print("Volviendo al menú principal...")

    root = tk.Tk()
    root.title("Formulario - Artista")
    root.geometry("700x650")
    root.config(bg="#f5f5f5")

    main_frame = tk.Frame(root, bg="#f5f5f5")
    main_frame.pack(expand=True, fill="both")

    mostrar_formulario_artista(main_frame, volver_callback=volver)

    root.mainloop()
