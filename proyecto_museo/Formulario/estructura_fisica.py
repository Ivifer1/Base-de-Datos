import tkinter as tk
from tkinter import ttk, messagebox
import psycopg2

class EstructuraFisicaApp:
    """
    Aplicación de Tkinter para la gestión de la estructura física de museos.
    Permite insertar nuevas estructuras físicas (edificios, pisos, áreas/secciones)
    asociadas a un museo seleccionado, y opcionalmente una sala de exposición
    si la estructura es un 'piso_planta'.
    """
    def __init__(self, root):
        self.root = root
        self.root.title("Registro de Estructura Física")
        self.root.geometry("600x750") # Aumentado para los nuevos campos de sala
        self.root.config(bg="#f5f5f5")

        # Configuración de estilos para ttk widgets (consistente con apps anteriores)
        self.style = ttk.Style()
        self.style.theme_use('clam') # Tema base

        self.style.configure('TFrame', background='#f5f5f5')
        self.style.configure('TLabel', background='#f5f5f5', foreground='#333', font=('Arial', 10))
        self.style.configure('TLabelframe', background='#f5f5f5', foreground='#333', font=('Arial', 12, 'bold'))
        self.style.configure('TLabelframe.Label', background='#f5f5f5', foreground='#333', font=('Arial', 12, 'bold'))
        self.style.configure('TEntry', fieldbackground='white', foreground='#333', font=('Arial', 10))
        self.style.configure('TCombobox', fieldbackground='white', foreground='#333', font=('Arial', 10))
        self.style.map('TCombobox', fieldbackground=[('readonly', 'white')])

        self.style.configure('TButton',
                             font=('Arial', 10, 'bold'),
                             background='#f5f5f5', # Color de fondo del botón
                             foreground='black',   # Color del texto del botón
                             padding=5)
        self.style.map('TButton',
                       background=[('active', '#f5f5f5')], # Color al pasar el ratón por encima
                       foreground=[('active', 'black')]
                      )

        # Conexión a la BD (ajusta parámetros)
        self.conn = psycopg2.connect(
            host="localhost",
            database="Museo",
            user="Grupo10",
            password="1234"
        )

        # Variables internas para almacenar listas de datos (id, nombre)
        self.museos = []
        self.estructuras_padre = [] # Estructuras existentes para seleccionar como padre

        # Contenedor principal del formulario
        self.main_frame = tk.Frame(self.root, bg="#f5f5f5")
        self.main_frame.pack(padx=20, pady=20, fill="both", expand=True)

        self.crear_widgets(self.main_frame)
        self.cargar_museos()

    def crear_widgets(self, parent_frame):
        """
        Crea y posiciona todos los widgets del formulario de estructura física.
        """
        tk.Label(
            parent_frame,
            text="Registro de Estructura Física",
            font=("Arial", 18, "bold"),
            bg="#f5f5f5",
            fg="#333"
        ).pack(pady=15)

        form_frame = ttk.LabelFrame(parent_frame, text="Datos de la Estructura", padding=20)
        form_frame.pack(padx=20, pady=10, fill="x", expand=False) # No expandir en Y aquí

        # Usamos un diccionario para almacenar las referencias a los widgets de entrada
        self.campos = {}

        # Definición de los campos del formulario de Estructura Física
        campos_data = [
            ("Museo:", "cb_museo", "combobox", []),
            ("Nombre de la Estructura *:", "entry_nombre_est", "entry"),
            ("Tipo de Estructura *:", "cb_tipo_est", "combobox", ["edi", "piso_planta", "area_seccion"]),
            ("Estructura Padre (si aplica):", "cb_est_padre", "combobox", []), # Este se carga dinámicamente
            ("Descripción:", "entry_descripcion_est", "entry"),
            ("Dirección del Edificio:", "entry_direccion_edificio", "entry"),
        ]

        row_idx = 0
        for label_text, var_name, widget_type, *args in campos_data:
            ttk.Label(form_frame, text=label_text).grid(row=row_idx, column=0, sticky="w", padx=10, pady=5)

            widget = None
            if widget_type == "combobox":
                widget = ttk.Combobox(form_frame, state="readonly", width=37)
                if args and args[0]: # Si se proporcionan valores para el combobox
                    widget['values'] = args[0]
            elif widget_type == "entry":
                widget = ttk.Entry(form_frame, width=40)

            setattr(self, var_name, widget) # Asignar el widget a un atributo de la clase
            self.campos[var_name] = widget # También guardar en un diccionario para fácil acceso

            widget.grid(row=row_idx, column=1, padx=10, pady=5, sticky="ew")
            row_idx += 1

        # Configuración de bindings para comboboxes que afectan a otros campos
        self.cb_museo.bind("<<ComboboxSelected>>", self.on_museo_seleccionado)
        self.cb_tipo_est.bind("<<ComboboxSelected>>", self.on_tipo_est_seleccionado)


        # --- Sección para Sala de Exposición (Opcional) ---
        self.sala_frame = ttk.LabelFrame(parent_frame, text="Datos de Sala de Exposición (Opcional)", padding=20)
        # Pack this frame conditionally later or manage its grid state
        self.sala_frame.pack(padx=20, pady=10, fill="x", expand=False)

        ttk.Label(self.sala_frame, text="Nombre de la Sala:").grid(row=0, column=0, sticky="w", padx=10, pady=5)
        self.entry_nombre_sala_exp = ttk.Entry(self.sala_frame, width=40, state='disabled')
        self.entry_nombre_sala_exp.grid(row=0, column=1, padx=10, pady=5, sticky="ew")
        self.campos['entry_nombre_sala_exp'] = self.entry_nombre_sala_exp # Add to campos dict

        ttk.Label(self.sala_frame, text="Descripción de la Sala:").grid(row=1, column=0, sticky="w", padx=10, pady=5)
        self.entry_descripcion_sala_exp = ttk.Entry(self.sala_frame, width=40, state='disabled')
        self.entry_descripcion_sala_exp.grid(row=1, column=1, padx=10, pady=5, sticky="ew")
        self.campos['entry_descripcion_sala_exp'] = self.entry_descripcion_sala_exp # Add to campos dict


        # Configuración inicial de visibilidad para campos condicionales
        self.on_tipo_est_seleccionado(None) # Llamar al inicio para establecer estado inicial

        # Botón Guardar
        button_frame = ttk.Frame(parent_frame, padding=10)
        button_frame.pack(pady=10)
        ttk.Button(button_frame, text="Guardar Estructura", command=self.guardar_estructura).pack(padx=10)

    def limpiar_campos(self):
        """Limpia todos los campos de entrada y resetea las selecciones."""
        self.cb_museo.set('')
        self.cb_tipo_est.set('')
        self.cb_est_padre.set('')
        self.entry_nombre_est.delete(0, tk.END)
        self.entry_descripcion_est.delete(0, tk.END)
        self.entry_direccion_edificio.delete(0, tk.END)
        self.entry_nombre_sala_exp.delete(0, tk.END) # Clear sala fields
        self.entry_descripcion_sala_exp.delete(0, tk.END) # Clear sala fields
        
        self.estructuras_padre = [] # Limpiar la lista interna
        self.cb_est_padre['values'] = [] # Limpiar el combobox de padre
        self.on_tipo_est_seleccionado(None) # Reestablecer visibilidad condicional
        self.cargar_museos() # Recargar museos por si acaso

    def cargar_museos(self):
        """Carga los museos desde la base de datos y actualiza el combobox."""
        cursor = None
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT id_museo, nombre_museo FROM museo ORDER BY id_museo")
            self.museos = cursor.fetchall()
            self.cb_museo['values'] = [m[1] for m in self.museos]
        except Exception as e:
            messagebox.showerror("Error de Carga", f"No se pudieron cargar los museos:\n{e}")
        finally:
            if cursor:
                cursor.close()

    def on_museo_seleccionado(self, event):
        """
        Se ejecuta cuando se selecciona un museo. Recarga las opciones para estructura padre
        y ajusta la visibilidad de los campos.
        """
        self.cb_est_padre.set('') # Limpiar selección de estructura padre
        self.estructuras_padre = [] # Limpiar la lista interna de padres

        if self.cb_museo.current() != -1:
            self.cargar_estructuras_padre()
        self.on_tipo_est_seleccionado(None) # Reajustar visibilidad según el tipo de estructura (si ya está seleccionado)

    def cargar_estructuras_padre(self):
        """
        Carga las estructuras físicas del museo seleccionado para ser usadas como padres.
        Filtra por el tipo de estructura padre permitido.
        """
        museo_idx = self.cb_museo.current()
        if museo_idx == -1:
            self.cb_est_padre['values'] = []
            self.estructuras_padre = []
            return

        museo_id = self.museos[museo_idx][0]
        tipo_est_actual = self.cb_tipo_est.get() # Tipo de la estructura que se está creando

        valid_parent_types = []
        if tipo_est_actual == 'piso_planta':
            valid_parent_types = ['edi']
        elif tipo_est_actual == 'area_seccion':
            valid_parent_types = ['edi', 'piso_planta']
        else: # Si es 'edi' o no hay tipo seleccionado, no hay padres válidos
            self.cb_est_padre['values'] = []
            self.estructuras_padre = []
            return # No hay padres si es 'edi' o tipo no definido

        cursor = None
        try:
            cursor = self.conn.cursor()
            sql = """
                SELECT id_est_fisica, nombre_est, tipo_est
                FROM public.estructura_fisica
                WHERE id_museo = %s
                  AND tipo_est = ANY(%s::character varying[])
                ORDER BY nombre_est;
            """
            cursor.execute(sql, (museo_id, valid_parent_types))
            self.estructuras_padre = cursor.fetchall()
            # Formato: "NombreEst (TipoEst)"
            self.cb_est_padre['values'] = [f"{e[1]} ({e[2]})" for e in self.estructuras_padre]
        except Exception as e:
            messagebox.showerror("Error de Carga", f"No se pudieron cargar las estructuras padre:\n{e}")
        finally:
            if cursor:
                cursor.close()


    def on_tipo_est_seleccionado(self, event):
        """
        Se ejecuta cuando se selecciona un tipo de estructura.
        Ajusta la visibilidad y el estado de los campos 'Dirección', 'Estructura Padre'
        y los nuevos campos de 'Sala de Exposición'.
        """
        tipo_seleccionado = self.cb_tipo_est.get()

        # Campo Dirección del Edificio
        if tipo_seleccionado == 'edi':
            self.campos['entry_direccion_edificio'].config(state='normal')
        else:
            self.campos['entry_direccion_edificio'].config(state='disabled')
            self.entry_direccion_edificio.delete(0, tk.END) # Limpiar si se deshabilita

        # Campo Estructura Padre
        if tipo_seleccionado in ['piso_planta', 'area_seccion']:
            self.campos['cb_est_padre'].config(state='readonly')
            self.cargar_estructuras_padre() # Recargar padres válidos para el tipo
        else:
            self.campos['cb_est_padre'].config(state='disabled')
            self.cb_est_padre.set('') # Limpiar selección de padre
            self.estructuras_padre = []
            self.cb_est_padre['values'] = [] # Limpiar opciones del combobox

        # Campos de Sala de Exposición
        if tipo_seleccionado == 'piso_planta':
            self.entry_nombre_sala_exp.config(state='normal')
            self.entry_descripcion_sala_exp.config(state='normal')
        else:
            self.entry_nombre_sala_exp.config(state='disabled')
            self.entry_descripcion_sala_exp.config(state='disabled')
            self.entry_nombre_sala_exp.delete(0, tk.END) # Limpiar si se deshabilita
            self.entry_descripcion_sala_exp.delete(0, tk.END)


    def guardar_estructura(self):
        """
        Valida los datos y guarda la nueva estructura física en la base de datos.
        Si la estructura es 'piso_planta' y se proporcionan datos de sala,
        también registra la sala de exposición.
        """
        museo_idx = self.cb_museo.current()
        nombre_est = self.entry_nombre_est.get().strip()
        tipo_est = self.cb_tipo_est.get()
        est_padre_idx = self.cb_est_padre.current()
        descripcion_est = self.entry_descripcion_est.get().strip() or None
        direccion_edificio = self.entry_direccion_edificio.get().strip() or None

        # Datos de Sala de Exposición (opcionales)
        nombre_sala_exp = self.entry_nombre_sala_exp.get().strip() or None
        descripcion_sala_exp = self.entry_descripcion_sala_exp.get().strip() or None

        # --- Validaciones de Estructura Física ---
        if museo_idx == -1:
            messagebox.showerror("Error de Validación", "Debe seleccionar un Museo.")
            return
        if not nombre_est:
            messagebox.showerror("Error de Validación", "El nombre de la estructura es obligatorio.")
            return
        if not tipo_est:
            messagebox.showerror("Error de Validación", "Debe seleccionar un Tipo de Estructura.")
            return

        if tipo_est == 'edi' and not direccion_edificio:
            messagebox.showerror("Error de Validación", "La dirección del edificio es obligatoria para estructuras tipo 'edi'.")
            return
        if tipo_est != 'edi' and direccion_edificio:
            messagebox.showwarning("Advertencia", "La dirección del edificio solo aplica para estructuras tipo 'edi'. Se ignorará este campo.")
            direccion_edificio = None

        id_museo = self.museos[museo_idx][0]
        id_est_padre = None
        if tipo_est in ['piso_planta', 'area_seccion']:
            if est_padre_idx == -1:
                messagebox.showerror("Error de Validación", "Debe seleccionar una Estructura Padre para este tipo de estructura.")
                return
            id_est_padre = self.estructuras_padre[est_padre_idx][0]

        # --- Validaciones de Sala de Exposición ---
        # If sala fields are filled, ensure type is 'piso_planta'
        if nombre_sala_exp or descripcion_sala_exp: # If user tried to fill any sala field
            if tipo_est != 'piso_planta':
                messagebox.showerror("Error de Validación", "Una Sala de Exposición solo puede ubicarse en un 'piso_planta'.")
                return
            if not nombre_sala_exp: # Nombre de sala es obligatorio si se intenta crear una sala
                messagebox.showerror("Error de Validación", "El nombre de la Sala de Exposición es obligatorio si desea registrar una sala.")
                return

        # --- Lógica de Inserción ---
        cursor = None
        try:
            cursor = self.conn.cursor()

            # Obtener el próximo id_est_fisica para el museo seleccionado
            cursor.execute("""
                SELECT COALESCE(MAX(id_est_fisica), 0) + 1
                FROM public.estructura_fisica
                WHERE id_museo = %s;
            """, (id_museo,))
            next_id_est_fisica = cursor.fetchone()[0]

            if next_id_est_fisica > 999:
                messagebox.showerror("Error de ID", "No se pueden crear más de 999 estructuras para este museo.")
                return

            # Insertar Estructura Física
            cursor.execute("""
                INSERT INTO public.estructura_fisica (
                    id_museo, id_est_fisica, id_est_padre, nombre_est,
                    tipo_est, descripcion_est, direccion_edificio
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                id_museo,
                next_id_est_fisica,
                id_est_padre,
                nombre_est,
                tipo_est,
                descripcion_est,
                direccion_edificio
            ))

            # Si es un piso_planta y se proporcionaron datos de sala, insertar Sala de Exposición
            if tipo_est == 'piso_planta' and nombre_sala_exp:
                # Obtener el próximo id_sala_exp para el museo y estructura física (piso)
                cursor.execute("""
                    SELECT COALESCE(MAX(id_sala_exp), 0) + 1
                    FROM public.sala_exp
                    WHERE id_museo = %s AND id_est_fisica = %s;
                """, (id_museo, next_id_est_fisica))
                next_id_sala_exp = cursor.fetchone()[0]

                if next_id_sala_exp > 999: # Assuming numeric(3,0) for id_sala_exp as well
                    messagebox.showerror("Error de ID", "No se pueden crear más de 999 salas para este piso/museo.")
                    self.conn.rollback() # Rollback the physical structure insertion too
                    return

                cursor.execute("""
                    INSERT INTO public.sala_exp (
                        id_museo, id_est_fisica, id_sala_exp, nombre_sala_expo, descripcion
                    ) VALUES (%s, %s, %s, %s, %s)
                """, (
                    id_museo,
                    next_id_est_fisica,
                    next_id_sala_exp,
                    nombre_sala_exp,
                    descripcion_sala_exp
                ))
                messagebox.showinfo("Éxito", "Estructura física y Sala de Exposición registradas correctamente.")
            else:
                messagebox.showinfo("Éxito", "Estructura física registrada correctamente.")

            self.conn.commit()
            self.limpiar_campos() # Limpiar el formulario después de guardar

        except Exception as e:
            if self.conn:
                self.conn.rollback()
            messagebox.showerror("Error de Base de Datos", f"No se pudo registrar la estructura:\n{e}")
        finally:
            if cursor:
                cursor.close()

if __name__ == "__main__":
    root = tk.Tk()
    app = EstructuraFisicaApp(root)
    root.mainloop()