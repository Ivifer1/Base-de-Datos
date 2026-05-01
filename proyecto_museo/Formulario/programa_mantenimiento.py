import tkinter as tk
from tkinter import ttk, messagebox
import datetime
import psycopg2
from tkcalendar import DateEntry

class CronogramaMantenimientoApp:

    def __init__(self, root):
        self.root = root
        self.root.title("Cronograma de Mantenimiento de Obras")
        # Establecer un color de fondo para la ventana principal para una estética limpia
        self.root.config(bg="#f5f5f5")

        # Configuración de estilos para los widgets ttk, inspirados en form_artista.py
        self.style = ttk.Style()
        self.style.theme_use('clam') # 'clam' o 'alt' suelen ser buenas bases para personalización profunda

        # Definición de estilos para diferentes elementos de la interfaz
        self.style.configure('TFrame', background='#f5f5f5')
        self.style.configure('TLabel', background='#f5f5f5', foreground='#333', font=('Arial', 10))
        # Estilo para el marco con título (LabelFrame)
        self.style.configure('TLabelframe', background='#f5f5f5', foreground='#333', font=('Arial', 12, 'bold'))
        # Estilo específico para el texto del título del LabelFrame
        self.style.configure('TLabelframe.Label', background='#f5f5f5', foreground='#333', font=('Arial', 12, 'bold'))
        self.style.configure('TEntry', fieldbackground='white', foreground='#333', font=('Arial', 10))
        self.style.configure('TCombobox', fieldbackground='white', foreground='#333', font=('Arial', 10))
        # Asegurar que el fondo del campo del Combobox sea blanco incluso en estado 'readonly'
        self.style.map('TCombobox', fieldbackground=[('readonly', 'white')])

        # Estilo para los botones, con colores que evocan una acción de guardar o confirmar
        self.style.configure('TButton',
                             font=('Arial', 10, 'bold'),
                             background='#f5f5f5', # Verde vibrante
                             foreground='black',   # Texto blanco para alto contraste
                             padding=5)
        # Cambios de estilo para los botones al interactuar con ellos (hover/active state)
        self.style.map('TButton',
                       background=[('active', '#f5f5f5')], # Un verde ligeramente más oscuro al hacer hover
                       foreground=[('active', 'black')]
                      )

        # Conexión a la Base de Datos PostgreSQL. Ajusta estos parámetros
        # según la configuración de tu entorno.
        self.conn = psycopg2.connect(
            host="localhost",
            database="Museo",
            user="Grupo10",
            password="1234"
        )

        # Variables internas para almacenar los datos de las listas desplegables
        # Contienen tuplas (id, nombre) para facilitar la gestión.
        self.museos = []
        self.empleados = []
        self.obras = []

        # Contenedor principal del formulario. Se empaqueta para que ocupe
        # el espacio disponible y proporcione padding alrededor de los widgets.
        self.main_frame = tk.Frame(self.root, bg="#f5f5f5")
        self.main_frame.pack(padx=20, pady=20, fill="both", expand=True)

        # Llamada a la función que crea y organiza todos los widgets de la interfaz
        self.crear_widgets(self.main_frame)
        # Cargar los museos disponibles al iniciar la aplicación
        self.cargar_museos()

    def crear_widgets(self, parent_frame):
        """
        Crea y posiciona todos los widgets de la interfaz de usuario dentro del 'parent_frame'.
        """
        # Título principal del formulario, visible y prominente.
        tk.Label(
            parent_frame,
            text="Cronograma de Mantenimiento",
            font=("Arial", 18, "bold"),
            bg="#f5f5f5",
            fg="#333"
        ).pack(pady=15)

        # LabelFrame para agrupar visualmente los campos del formulario,
        # similar al diseño utilizado en form_artista.py.
        form_frame = ttk.LabelFrame(parent_frame, text="Detalles del Cronograma", padding=20)
        form_frame.pack(padx=20, pady=10, fill="both", expand=True)

        # Definición de los campos del formulario usando una lista de tuplas para
        # una creación más programática y mantenible.
        # Cada tupla contiene: (Etiqueta, Nombre de atributo, Tipo de widget, [Valores opcionales])
        campos_data = [
            ("Museo:", "cb_museo", "combobox"),
            ("Cargo:", "cb_cargo", "combobox", ["curador", "restaurador"]),
            ("Empleado:", "cb_empleado", "combobox"),
            ("Obra:", "cb_obra", "combobox"),
            ("Frecuencia:", "entry_frecuencia", "entry"),
            ("Actividad:", "entry_actividad", "entry"),
            ("Descripción (opcional):", "entry_descripcion", "entry"),
            ("Fecha inicio:", "entry_fecha_inicio", "dateentry"),
        ]

        row_idx = 0
        for label_text, var_name, widget_type, *args in campos_data:
            # Crea y posiciona la etiqueta para cada campo
            ttk.Label(form_frame, text=label_text).grid(row=row_idx, column=0, sticky="w", padx=10, pady=5)

            widget = None # Inicializar widget para evitar UnboundLocalError
            # Crea el widget correspondiente según su tipo
            if widget_type == "combobox":
                widget = ttk.Combobox(form_frame, state="readonly", width=37)
                if args: # Si hay valores específicos para el combobox (ej. "curador", "restaurador")
                    widget['values'] = args[0]
            elif widget_type == "entry":
                widget = ttk.Entry(form_frame, width=40)
            elif widget_type == "dateentry":
                # DateEntry para selección de fechas con un formato específico
                widget = DateEntry(form_frame, date_pattern="yyyy-mm-dd", width=38, background='darkblue',
                                   foreground='white', borderwidth=2)
                widget.set_date(datetime.date.today()) # Establece la fecha actual por defecto

            # Asigna el widget creado como un atributo de la instancia de la clase (self.cb_museo, etc.)
            setattr(self, var_name, widget)
            # Posiciona el widget en la cuadrícula
            widget.grid(row=row_idx, column=1, padx=10, pady=5, sticky="ew")
            row_idx += 1

        # Configuración de bindings para los Comboboxes que desencadenan la carga de otros datos
        self.cb_museo.bind("<<ComboboxSelected>>", self.on_museo_cargo_cambio)
        self.cb_cargo.bind("<<ComboboxSelected>>", self.on_museo_cargo_cambio)

        # Botón para guardar el cronograma. Se coloca en su propio frame para control de posición.
        button_frame = ttk.Frame(parent_frame, padding=10)
        button_frame.pack(pady=10)
        self.btn_guardar = ttk.Button(button_frame, text="Guardar Cronograma", command=self.guardar_cronograma)
        self.btn_guardar.pack(padx=10)

    def cargar_museos(self):
        """
        Carga los museos desde la base de datos y actualiza el Combobox de museos.
        """
        cursor = None # Inicializar cursor
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT id_museo, nombre_museo FROM museo ORDER BY nombre_museo")
            self.museos = cursor.fetchall()
        except Exception as e:
            messagebox.showerror("Error de Carga", f"No se pudieron cargar los museos:\n{e}")
        finally:
            if cursor:
                cursor.close()

        self.cb_museo['values'] = [m[1] for m in self.museos]

    def on_museo_cargo_cambio(self, event):
        """
        Manejador de eventos para cuando cambia la selección de museo o cargo.
        Recarga las listas de empleados y obras según las selecciones actuales.
        """
        # Si no hay un museo seleccionado, limpiar las listas de empleados y obras
        if self.cb_museo.current() == -1:
            self.cb_empleado['values'] = []
            self.cb_obra['values'] = []
            self.empleados = []
            self.obras = []
        else:
            # Si hay un museo seleccionado, cargar empleados y obras relevantes
            self.cargar_empleados()
            self.cargar_obras()

    def cargar_empleados(self):
    
        museo_idx = self.cb_museo.current()
        cargo = self.cb_cargo.get()

        # Si no hay selección válida de museo o cargo, limpiar y salir
        if museo_idx == -1 or cargo not in ("curador", "restaurador"):
            self.cb_empleado['values'] = []
            self.empleados = []
            return

        museo_id = self.museos[museo_idx][0]
        cursor = None # Inicializar cursor
        try:
            cursor = self.conn.cursor()
            sql = """
                SELECT ep.id_emp_pro, ep.primer_nombre, ep.primer_apellido
                FROM empleado_profesional ep
                JOIN historico_empleado he ON ep.id_emp_pro = he.id_emp_pro
                WHERE he.id_museo = %s AND LOWER(he.cargo) = LOWER(%s)
                AND he.fecha_fin IS NULL -- Solo empleados con este cargo ACTIVO
            """
            cursor.execute(sql, (museo_id, cargo))
            self.empleados = cursor.fetchall()
        except Exception as e:
            messagebox.showerror("Error de Carga", f"No se pudieron cargar los empleados:\n{e}")
        finally:
            if cursor:
                cursor.close()

        nombres = [f"{e[1]} {e[2]}" for e in self.empleados]
        self.cb_empleado['values'] = nombres
        self.cb_empleado.set('') # Limpiar la selección actual del combobox

    def cargar_obras(self):
        """
        Carga las obras asociadas al museo seleccionado que están activas
        y actualiza el Combobox de obras.
        """
        museo_idx = self.cb_museo.current()
        if museo_idx == -1:
            self.cb_obra['values'] = []
            self.obras = []
            return

        museo_id = self.museos[museo_idx][0]
        cursor = None # Inicializar cursor
        try:
            cursor = self.conn.cursor()
            sql = """
                SELECT DISTINCT o.id_obra, o.nom_obra, hom.id_cata_museo -- Incluye id_cata_museo desde hom
                FROM obra o
                JOIN hist_obra_movimiento hom ON o.id_obra = hom.id_obra
                WHERE hom.id_museo = %s AND (hom.fecha_fin IS NULL OR hom.fecha_fin > CURRENT_DATE)
                ORDER BY o.nom_obra
            """
            cursor.execute(sql, (museo_id,))
            self.obras = cursor.fetchall()
        except Exception as e:
            messagebox.showerror("Error de Carga", f"No se pudieron cargar las obras:\n{e}")
        finally:
            if cursor:
                cursor.close()

        titulos = [o[1] for o in self.obras]
        self.cb_obra['values'] = titulos
        self.cb_obra.set('') # Limpiar la selección actual del combobox

    def guardar_cronograma(self):
        """
        Valida los datos del formulario y los guarda en las tablas
        'actividad_conservacion' e 'hist_conservacion' de la base de datos.
        """
        # Obtener los índices de los elementos seleccionados en los Comboboxes
        empleado_idx = self.cb_empleado.current()
        obra_idx = self.cb_obra.current()

        # Obtener los valores de los campos de entrada, eliminando espacios en blanco extra
        frecuencia = self.entry_frecuencia.get().strip()
        actividad = self.entry_actividad.get().strip()
        fecha_inicio_date = self.entry_fecha_inicio.get_date() # Obtiene un objeto datetime.date
        descripcion = self.entry_descripcion.get().strip() or None # Usa None si la descripción está vacía
        cargo = self.cb_cargo.get() # Obtener el cargo seleccionado del combobox

        # Validación de campos obligatorios y selecciones de Combobox
        if empleado_idx == -1 or obra_idx == -1 or not frecuencia or not actividad or cargo not in ("curador", "restaurador"):
            messagebox.showerror("Error de Validación", "Debe completar todos los campos obligatorios y realizar selecciones válidas.")
            return

        # Obtener los IDs de los elementos seleccionados
        empleado_id = self.empleados[empleado_idx][0] # ID del empleado
        obra_id = self.obras[obra_idx][0]             # ID de la obra
        id_cata_museo_obra = self.obras[obra_idx][2]  # ID de catálogo del museo para la obra

        cursor = None # Inicializar cursor
        try:
            cursor = self.conn.cursor()

            # Insertar en la tabla 'actividad_conservacion'
            # Se usa RETURNING para obtener el id_conservacion generado automáticamente
            cursor.execute("""
                INSERT INTO actividad_conservacion (id_obra, id_cata_museo, actividad, frecuencia, tipo_responsable)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id_conservacion
            """, (obra_id, id_cata_museo_obra, actividad, frecuencia, cargo))
            id_conservacion = cursor.fetchone()[0]

            # Insertar en la tabla 'hist_conservacion'
            # fecha_fin_cons es NULL inicialmente para indicar que la actividad está en curso
            cursor.execute("""
                INSERT INTO hist_conservacion (
                    id_obra, id_cata_museo, id_conservacion, id_emp_pro,
                    fecha_inicio_cons, fecha_fin_cons, descripcion
                ) VALUES (%s, %s, %s, %s, %s, NULL, %s)
            """, (obra_id, id_cata_museo_obra, id_conservacion, empleado_id, fecha_inicio_date, descripcion))

            # Confirmar los cambios en la base de datos
            self.conn.commit()
            messagebox.showinfo("Éxito", "Cronograma de mantenimiento guardado correctamente.")

            # Limpiar los campos del formulario después de una inserción exitosa
            self.entry_frecuencia.delete(0, tk.END)
            self.entry_actividad.delete(0, tk.END)
            self.entry_descripcion.delete(0, tk.END)
            self.cb_empleado.set('')
            self.cb_obra.set('')
            self.entry_fecha_inicio.set_date(datetime.date.today())
            self.cb_museo.set('') # Limpiar museo y cargo para forzar recarga si se cambia de selección
            self.cb_cargo.set('')
            # Opcional: recargar empleados y obras si el museo/cargo se limpian
            self.on_museo_cargo_cambio(None) # Simular evento para recargar listas vacías

        except Exception as e:
            # En caso de error, revertir cualquier cambio en la base de datos
            if self.conn:
                self.conn.rollback()
            messagebox.showerror("Error de Base de Datos", f"No se pudo guardar el cronograma:\n{e}")
        finally:
            # Asegurarse de que el cursor se cierre siempre, si fue creado
            if cursor:
                cursor.close()


if __name__ == "__main__":
    root = tk.Tk()
    app = CronogramaMantenimientoApp(root)
    root.mainloop()

