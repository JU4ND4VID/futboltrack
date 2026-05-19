# ================================================================
# FutbolTrack - app/utils/validators.py
# Validaciones reutilizables para todos los endpoints.
# Uso:
#   from app.utils.validators import validar, VE
#   error = validar(d, [...reglas...])
#   if error: return jsonify({"ok": False, "mensaje": error}), 400
# ================================================================
import re
from datetime import date, datetime


class VE(Exception):
    """Validation Error — se lanza y se captura dentro de `validar()`."""
    pass


# ── Helpers básicos ───────────────────────────────────────────────

def _solo_letras(valor, campo):
    if not re.fullmatch(r"[A-Za-záéíóúÁÉÍÓÚüÜñÑ\s\-]+", valor.strip()):
        raise VE(f"'{campo}' solo puede contener letras y espacios.")

def _solo_numeros(valor, campo):
    if not re.fullmatch(r"\d+", valor.strip()):
        raise VE(f"'{campo}' solo puede contener dígitos.")

def _longitud(valor, campo, minimo, maximo):
    v = valor.strip()
    if len(v) < minimo:
        raise VE(f"'{campo}' debe tener al menos {minimo} caracteres.")
    if len(v) > maximo:
        raise VE(f"'{campo}' no puede superar {maximo} caracteres.")

def _requerido(valor, campo):
    if not str(valor or "").strip():
        raise VE(f"El campo '{campo}' es obligatorio.")

def _en_lista(valor, campo, opciones):
    if valor not in opciones:
        raise VE(f"'{campo}' debe ser uno de: {', '.join(opciones)}.")

def _fecha_valida(valor, campo):
    try:
        datetime.strptime(str(valor).strip(), "%Y-%m-%d")
    except ValueError:
        raise VE(f"'{campo}' debe tener formato YYYY-MM-DD (ej. 2010-03-15).")

def _hora_valida(valor, campo):
    try:
        datetime.strptime(str(valor).strip(), "%H:%M")
    except ValueError:
        raise VE(f"'{campo}' debe tener formato HH:MM (ej. 08:30).")

def _numero_positivo(valor, campo, minimo=0, maximo=None):
    try:
        n = float(valor)
    except (TypeError, ValueError):
        raise VE(f"'{campo}' debe ser un número.")
    if n < minimo:
        raise VE(f"'{campo}' debe ser mayor o igual a {minimo}.")
    if maximo is not None and n > maximo:
        raise VE(f"'{campo}' no puede superar {maximo}.")


# ── Validadores específicos por entidad ───────────────────────────

def validar_jugador_crear(d):
    errores = []
    def chk(fn, *a):
        try: fn(*a)
        except VE as e: errores.append(str(e))

    chk(_requerido,      d.get("identificacion_jugador"), "identificacion_jugador")
    chk(_solo_numeros,   str(d.get("identificacion_jugador", "")), "identificacion_jugador")
    chk(_longitud,       str(d.get("identificacion_jugador", "")), "identificacion_jugador", 5, 15)

    chk(_requerido,      d.get("nombre_jugador"),  "nombre_jugador")
    chk(_solo_letras,    str(d.get("nombre_jugador",  "")), "nombre_jugador")
    chk(_longitud,       str(d.get("nombre_jugador",  "")), "nombre_jugador",  2, 45)

    chk(_requerido,      d.get("apellido_jugador"), "apellido_jugador")
    chk(_solo_letras,    str(d.get("apellido_jugador", "")), "apellido_jugador")
    chk(_longitud,       str(d.get("apellido_jugador", "")), "apellido_jugador", 2, 45)

    chk(_requerido,      d.get("fecha_nacimiento"), "fecha_nacimiento")
    chk(_fecha_valida,   d.get("fecha_nacimiento"), "fecha_nacimiento")

    # Verificar que la fecha no sea futura ni mayor a 100 años
    if not errores:
        fn = datetime.strptime(str(d["fecha_nacimiento"]).strip(), "%Y-%m-%d").date()
        if fn >= date.today():
            errores.append("'fecha_nacimiento' debe ser una fecha pasada.")
        elif (date.today() - fn).days > 365 * 100:
            errores.append("'fecha_nacimiento' no es válida.")

    posiciones = ["portero", "defensa", "mediocampista", "delantero", "lateral"]
    chk(_requerido,  d.get("posicion"), "posicion")
    if str(d.get("posicion", "")).strip().lower() not in posiciones:
        errores.append(f"'posicion' debe ser una de: {', '.join(posiciones)}.")

    chk(_requerido,        d.get("id_categoria"), "id_categoria")
    chk(_numero_positivo,  d.get("id_categoria"), "id_categoria", 1)

    chk(_requerido,      d.get("cedula_acudiente"),    "cedula_acudiente")
    chk(_solo_numeros,   str(d.get("cedula_acudiente", "")), "cedula_acudiente")
    chk(_longitud,       str(d.get("cedula_acudiente", "")), "cedula_acudiente", 5, 15)

    chk(_requerido,      d.get("nombre_acudiente"),    "nombre_acudiente")
    chk(_solo_letras,    str(d.get("nombre_acudiente",   "")), "nombre_acudiente")
    chk(_longitud,       str(d.get("nombre_acudiente",   "")), "nombre_acudiente",  2, 45)

    chk(_requerido,      d.get("apellido_acudiente"),  "apellido_acudiente")
    chk(_solo_letras,    str(d.get("apellido_acudiente", "")), "apellido_acudiente")
    chk(_longitud,       str(d.get("apellido_acudiente", "")), "apellido_acudiente", 2, 45)

    chk(_requerido,      d.get("telefono_acudiente"),  "telefono_acudiente")
    chk(_solo_numeros,   str(d.get("telefono_acudiente", "")), "telefono_acudiente")
    chk(_longitud,       str(d.get("telefono_acudiente", "")), "telefono_acudiente", 7, 15)

    parentescos = ["padre", "madre", "abuelo", "abuela", "tio", "tia",
                   "hermano", "hermana", "tutor", "otro"]
    chk(_requerido, d.get("parentesco"), "parentesco")
    if str(d.get("parentesco", "")).strip().lower() not in parentescos:
        errores.append(f"'parentesco' debe ser uno de: {', '.join(parentescos)}.")

    return errores


def validar_jugador_editar(d):
    errores = []
    def chk(fn, *a):
        try: fn(*a)
        except VE as e: errores.append(str(e))

    if d.get("nombre"):
        chk(_solo_letras, str(d["nombre"]), "nombre")
        chk(_longitud,    str(d["nombre"]), "nombre", 2, 45)

    if d.get("apellido"):
        chk(_solo_letras, str(d["apellido"]), "apellido")
        chk(_longitud,    str(d["apellido"]), "apellido", 2, 45)

    if d.get("fecha_nacimiento"):
        chk(_fecha_valida, d["fecha_nacimiento"], "fecha_nacimiento")
        fn = datetime.strptime(str(d["fecha_nacimiento"]).strip(), "%Y-%m-%d").date()
        if fn >= date.today():
            errores.append("'fecha_nacimiento' debe ser una fecha pasada.")

    posiciones = ["portero", "defensa", "mediocampista", "delantero", "lateral"]
    if d.get("posicion") and str(d["posicion"]).strip().lower() not in posiciones:
        errores.append(f"'posicion' debe ser una de: {', '.join(posiciones)}.")

    if d.get("nombre_acudiente"):
        chk(_solo_letras, str(d["nombre_acudiente"]), "nombre_acudiente")
        chk(_longitud,    str(d["nombre_acudiente"]), "nombre_acudiente", 2, 45)

    if d.get("apellido_acudiente"):
        chk(_solo_letras, str(d["apellido_acudiente"]), "apellido_acudiente")
        chk(_longitud,    str(d["apellido_acudiente"]), "apellido_acudiente", 2, 45)

    if d.get("telefono_acudiente"):
        chk(_solo_numeros, str(d["telefono_acudiente"]), "telefono_acudiente")
        chk(_longitud,     str(d["telefono_acudiente"]), "telefono_acudiente", 7, 15)

    return errores


def validar_entrenamiento_crear(d):
    errores = []
    def chk(fn, *a):
        try: fn(*a)
        except VE as e: errores.append(str(e))

    chk(_requerido,   d.get("fecha"),       "fecha")
    chk(_fecha_valida, d.get("fecha"),      "fecha")

    chk(_requerido,   d.get("hora_inicio"), "hora_inicio")
    chk(_hora_valida, d.get("hora_inicio"), "hora_inicio")

    chk(_requerido,   d.get("hora_fin"),    "hora_fin")
    chk(_hora_valida, d.get("hora_fin"),    "hora_fin")

    # Verificar que hora_fin > hora_inicio
    if not errores:
        try:
            hi = datetime.strptime(str(d["hora_inicio"]).strip(), "%H:%M")
            hf = datetime.strptime(str(d["hora_fin"]).strip(),    "%H:%M")
            if hf <= hi:
                errores.append("'hora_fin' debe ser posterior a 'hora_inicio'.")
        except Exception:
            pass

    tipos = ["tecnico", "fisico", "tactico", "mixto"]
    chk(_requerido, d.get("tipo"), "tipo")
    if str(d.get("tipo", "")).strip().lower() not in tipos:
        errores.append(f"'tipo' debe ser uno de: {', '.join(tipos)}.")

    chk(_requerido,       d.get("id_lugar"),          "id_lugar")
    chk(_numero_positivo, d.get("id_lugar"),           "id_lugar", 1)

    chk(_requerido,       d.get("id_categoria"),       "id_categoria")
    chk(_numero_positivo, d.get("id_categoria"),        "id_categoria", 1)

    chk(_requerido,       d.get("cedula_entrenador"),  "cedula_entrenador")
    chk(_solo_numeros,    str(d.get("cedula_entrenador", "")), "cedula_entrenador")

    return errores


def validar_estado_entrenamiento(estado):
    estados = ["programado", "realizado", "cancelado"]
    if str(estado or "").strip().lower() not in estados:
        return [f"'estado' debe ser uno de: {', '.join(estados)}."]
    return []


def validar_asistencia(lista):
    errores = []
    estados_validos = ["presente", "ausente", "justificado"]
    for i, item in enumerate(lista):
        if not str(item.get("identificacion_jugador", "")).strip():
            errores.append(f"Registro #{i+1}: falta 'identificacion_jugador'.")
        estado = str(item.get("estado_asistencia", "")).strip()
        if estado not in estados_validos:
            errores.append(
                f"Registro #{i+1}: 'estado_asistencia' debe ser "
                f"{', '.join(estados_validos)}."
            )
    return errores


def validar_plan_sesion(d):
    errores = []
    if not str(d.get("calentamiento", "")).strip():
        errores.append("'calentamiento' es obligatorio.")
    elif len(str(d["calentamiento"]).strip()) < 5:
        errores.append("'calentamiento' debe tener al menos 5 caracteres.")

    bloques = d.get("bloques", [])
    if not isinstance(bloques, list) or len(bloques) == 0:
        errores.append("Debe incluir al menos un bloque de trabajo.")
    else:
        for i, b in enumerate(bloques):
            if not str(b.get("nombre", "")).strip():
                errores.append(f"Bloque #{i+1}: el nombre es obligatorio.")
            try:
                dur = int(b.get("duracion_min", 0))
                if dur <= 0:
                    errores.append(f"Bloque #{i+1}: 'duracion_min' debe ser mayor a 0.")
            except (TypeError, ValueError):
                errores.append(f"Bloque #{i+1}: 'duracion_min' debe ser un número.")

    return errores


def validar_estadisticas(lista):
    errores = []
    for i, item in enumerate(lista):
        if not str(item.get("cedula_jugador", "")).strip():
            errores.append(f"Jugador #{i+1}: falta 'cedula_jugador'.")
        try:
            dist = float(item.get("distancia_km", -1))
            if dist < 0:
                errores.append(f"Jugador #{i+1}: 'distancia_km' debe ser >= 0.")
        except (TypeError, ValueError):
            errores.append(f"Jugador #{i+1}: 'distancia_km' debe ser un número.")
        try:
            nota = float(item.get("nota", -1))
            if not (0 <= nota <= 10):
                errores.append(f"Jugador #{i+1}: 'nota' debe estar entre 0 y 10.")
        except (TypeError, ValueError):
            errores.append(f"Jugador #{i+1}: 'nota' debe ser un número.")
    return errores


def validar_observaciones(d):
    errores = []
    obs = str(d.get("observacion_general", "")).strip()
    if not obs:
        errores.append("'observacion_general' es obligatorio.")
    elif len(obs) < 10:
        errores.append("'observacion_general' debe tener al menos 10 caracteres.")

    for campo in ["aspectos_positivos", "aspectos_a_mejorar"]:
        lista = d.get(campo, [])
        if isinstance(lista, list):
            for item in lista:
                if not re.fullmatch(r"[A-Za-záéíóúÁÉÍÓÚüÜñÑ0-9\s\.\,\-]+",
                                    str(item).strip()):
                    errores.append(
                        f"'{campo}': '{item}' contiene caracteres no permitidos."
                    )
    return errores
