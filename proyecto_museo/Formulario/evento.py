import tkinter as tk
from tkinter import ttk, messagebox
from conexion import conectar  # Asegúrate que este módulo exista y funcione
from datetime import datetime

def limpiar_frame(frame):
    for widget in frame.winfo_children():
        widget.destroy()

def mostrar_formulario_evento(content_frame, volver_callback=None):
    limpiar_frame(content_frame)

    tk.Label(
        content_frame,
        text="Registro de Eventos",
        font=("Arial", 18, "bold"),
        bg="#f5f5f5",
        fg="#333"
    ).pack(pady=10)

    frame = ttk.LabelFrame(content_frame, text="Datos del Evento", padding=15)
    frame.pack(padx=20, pady=10, fill="both", expand=True)

    campos = {}
    row_idx = 0

    ttk.Label(frame, text="Museo:").grid(row=row_idx, column=0, sticky="w", pady=5)
    combo_museo = ttk.Combobox(frame, state="readonly", width=38)
    combo_museo.grid(row=row_idx, column=1, padx=10, pady=5)
    campos['museo'] = combo_museo
    row_idx += 1

    ttk.Label(frame, text="Título del evento:").grid(row=row_idx, column=0, sticky="w", pady=5)
    entry_titulo = ttk.Entry(frame, width=40)
    entry_titulo.grid(row=row_idx, column=1, padx=10, pady=5)
    campos['titulo'] = entry_titulo
    row_idx += 1

    ttk.Label(frame, text="Fecha inicio (YYYY-MM-DD):").grid(row=row_idx, column=0, sticky="w", pady=5)
    entry_fecha_inicio = ttk.Entry(frame, width=40)
    entry_fecha_inicio.grid(row=row_idx, column=1, padx=10, pady=5)
    campos['fecha_inicio'] = entry_fecha_inicio
    row_idx += 1

    ttk.Label(frame, text="Fecha fin (YYYY-MM-DD):").grid(row=row_idx, column=0, sticky="w", pady=5)
    entry_fecha_fin = ttk.Entry(frame, width=40)
    entry_fecha_fin.grid(row=row_idx, column=1, padx=10, pady=5)
    campos['fecha_fin'] = entry_fecha_fin
    row_idx += 1

    ttk.Label(frame, text="Lugar de exposición:").grid(row=row_idx, column=0, sticky="w", pady=5)
    entry_lugar = ttk.Entry(frame, width=40)
    entry_lugar.grid(row=row_idx, column=1, padx=10, pady=5)
    campos['lugar'] = entry_lugar
    row_idx += 1

    ttk.Label(frame, text="Costo $:").grid(row=row_idx, column=0, sticky="w", pady=5)
    entry_costo = ttk.Entry(frame, width=40)
    entry_costo.grid(row=row_idx, column=1, padx=10, pady=5)
    campos['costo'] = entry_costo
    row_idx += 1

    ttk.Label(frame, text="Cantidad personas:").grid(row=row_idx, column=0, sticky="w", pady=5)
    entry_cant_personas = ttk.Entry(frame, width=40)
    entry_cant_personas.grid(row=row_idx, column=1, padx=10, pady=5)
    campos['cant_personas'] = entry_cant_personas
    row_idx += 1

    ttk.Label(frame, text="Institución educativa:").grid(row=row_idx, column=0, sticky="w", pady=5)
    entry_institucion = ttk.Entry(frame, width=40)
    entry_institucion.grid(row=row_idx, column=1, padx=10, pady=5)
    campos['institucion'] = entry_institucion
    row_idx += 1

    def limpiar_campos_evento():
        campos['museo'].set('')
        campos['titulo'].delete(0, tk.END)
        campos['fecha_inicio'].delete(0, tk.END)
        campos['fecha_fin'].delete(0, tk.END)
        campos['lugar'].delete(0, tk.END)
        campos['costo'].delete(0, tk.END)
        campos['cant_personas'].delete(0, tk.END)
        campos['institucion'].delete(0, tk.END)

    def cargar_museos():
        try:
            conn = conectar()
            cur = conn.cursor()
            cur.execute("SELECT id_museo, nombre_museo FROM museo ORDER BY id_museo")
            resultados = cur.fetchall()
            museos = [f"{id_museo} - {nombre}" for id_museo, nombre in resultados]
            combo_museo['values'] = museos
        except Exception as e:
            messagebox.showerror("Error", f"No se pudieron cargar los museos:\n{e}")
        finally:
            if conn:
                conn.close()

    cargar_museos()

    def guardar_evento():
        museo_seleccionado = campos['museo'].get()
        if not museo_seleccionado:
            messagebox.showwarning("Campo obligatorio", "Selecciona un museo.")
            return

        try:
            id_museo = int(museo_seleccionado.split(" - ")[0])
        except ValueError:
            messagebox.showwarning("Error de Selección", "El museo seleccionado no es válido.")
            return

        titulo = campos['titulo'].get().strip()
        if not titulo:
            messagebox.showwarning("Campo obligatorio", "El Título del evento es obligatorio.")
            return

        fecha_inicio_str = campos['fecha_inicio'].get().strip()
        if not fecha_inicio_str:
            messagebox.showwarning("Campo obligatorio", "La Fecha de inicio es obligatoria.")
            return
        try:
            fecha_inicio = datetime.strptime(fecha_inicio_str, "%Y-%m-%d").date()
        except ValueError:
            messagebox.showwarning("Formato inválido", "La Fecha de inicio debe ser YYYY-MM-DD.")
            return

        fecha_fin_str = campos['fecha_fin'].get().strip()
        if not fecha_fin_str:
            messagebox.showwarning("Campo obligatorio", "La Fecha de fin es obligatoria.")
            return
        try:
            fecha_fin = datetime.strptime(fecha_fin_str, "%Y-%m-%d").date()
        except ValueError:
            messagebox.showwarning("Formato inválido", "La Fecha de fin debe ser YYYY-MM-DD.")
            return

        if fecha_inicio > fecha_fin:
            messagebox.showwarning("Error de Fechas", "La fecha de inicio no puede ser posterior a la fecha de fin.")
            return

        lugar = campos['lugar'].get().strip()
        if not lugar:
            messagebox.showwarning("Campo obligatorio", "El Lugar de exposición es obligatorio.")
            return

        costo_texto = campos['costo'].get().strip()
        costo = None
        if costo_texto:
            try:
                costo = float(costo_texto)
            except ValueError:
                messagebox.showwarning("Formato inválido", "El Costo debe ser un número.")
                return

        cant_personas_texto = campos['cant_personas'].get().strip()
        cantidad_personas = None
        if cant_personas_texto:
            try:
                cantidad_personas = int(cant_personas_texto)
            except ValueError:
                messagebox.showwarning("Formato inválido", "Cantidad de personas debe ser un número entero.")
                return

        institucion = campos['institucion'].get().strip() or None

        conn = None
        try:
            conn = conectar()
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO evento (
                    id_museo, titulo_evento, fecha_inicio_evento, fecha_fin_evento,
                    lugar_exposicion, costo, cantidad_personas, institucion_educativa
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                id_museo, titulo, fecha_inicio, fecha_fin,
                lugar, costo, cantidad_personas, institucion
            ))
            conn.commit()
            messagebox.showinfo("Éxito", "Evento registrado correctamente.")
            limpiar_campos_evento()

        except Exception as e:
            if conn:
                conn.rollback()
            messagebox.showerror("Error", f"Ocurrió un error al guardar el evento: {e}")
        finally:
            if conn:
                conn.close()

    button_frame = ttk.Frame(content_frame, padding=10)
    button_frame.pack(pady=10)

    ttk.Button(button_frame, text="Guardar Evento", command=guardar_evento).pack(side="left", padx=10)

# Ejemplo para testear el formulario independiente
if __name__ == "__main__":
    def volver():
        print("Volver al menú principal (a implementar)")

    root = tk.Tk()
    root.title("Formulario de Evento")
    root.geometry("700x500")

    frame = tk.Frame(root, bg="#f5f5f5")
    frame.pack(expand=True, fill="both")

    mostrar_formulario_evento(frame, volver_callback=volver)

    root.mainloop()
