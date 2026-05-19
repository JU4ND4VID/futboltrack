// ================================================================
// FutbolTrack — Seed MongoDB
// Colecciones: planes_sesion, estadisticas_jugador, observaciones_sesion
// Ejecutar en mongosh: load('mongo_seed.js')
// ================================================================

use futboltrack;

// Limpiar colecciones (por si acaso)
db.planes_sesion.deleteMany({});
db.estadisticas_jugador.deleteMany({});
db.observaciones_sesion.deleteMany({});

// ── 1. PLANES DE SESIÓN ──────────────────────────────────────
db.planes_sesion.insertMany(
[
  {
    "id_entrenamiento_mysql": 1,
    "categoria": "Sub-17",
    "objetivo_sesion": "Trabajar la presión tras pérdida",
    "duracion_total_min": 120,
    "materiales": [
      "Balones",
      "Petos",
      "Vallas"
    ],
    "fases": [
      {
        "nombre": "Calentamiento",
        "duracion_min": 20,
        "descripcion": "Skipping y cambios de ritmo"
      },
      {
        "nombre": "Parte Principal",
        "duracion_min": 70,
        "descripcion": "Posicionamiento defensivo 4-4-2"
      },
      {
        "nombre": "Vuelta a la calma",
        "duracion_min": 30,
        "descripcion": "Estiramientos estáticos"
      }
    ],
    "entrenador": "Carlos Herrera"
  },
  {
    "id_entrenamiento_mysql": 2,
    "categoria": "Sub-17",
    "objetivo_sesion": "Aumentar velocidad en transición",
    "duracion_total_min": 120,
    "materiales": [
      "Escaleras de coordinación",
      "Bandas elásticas",
      "Cronómetro"
    ],
    "fases": [
      {
        "nombre": "Calentamiento",
        "duracion_min": 20,
        "descripcion": "Rondos de activación"
      },
      {
        "nombre": "Parte Principal",
        "duracion_min": 70,
        "descripcion": "Circuito físico-técnico"
      },
      {
        "nombre": "Vuelta a la calma",
        "duracion_min": 30,
        "descripcion": "Hidratación y retroalimentación"
      }
    ],
    "entrenador": "Carlos Herrera"
  },
  {
    "id_entrenamiento_mysql": 3,
    "categoria": "Sub-17",
    "objetivo_sesion": "Consolidar el esquema táctico 4-3-3",
    "duracion_total_min": 120,
    "materiales": [
      "Bandas elásticas",
      "Escaleras de coordinación",
      "Arcos pequeños",
      "Balones",
      "Conos"
    ],
    "fases": [
      {
        "nombre": "Calentamiento",
        "duracion_min": 20,
        "descripcion": "Skipping y cambios de ritmo"
      },
      {
        "nombre": "Parte Principal",
        "duracion_min": 70,
        "descripcion": "Táctico: pressing alto"
      },
      {
        "nombre": "Vuelta a la calma",
        "duracion_min": 30,
        "descripcion": "Vuelta a la calma en parejas"
      }
    ],
    "entrenador": "Carlos Herrera"
  },
  {
    "id_entrenamiento_mysql": 4,
    "categoria": "Sub-15",
    "objetivo_sesion": "Aumentar velocidad en transición",
    "duracion_total_min": 120,
    "materiales": [
      "Escaleras de coordinación",
      "Petos",
      "Arcos pequeños",
      "Vallas",
      "Bandas elásticas"
    ],
    "fases": [
      {
        "nombre": "Calentamiento",
        "duracion_min": 20,
        "descripcion": "Rondos de activación"
      },
      {
        "nombre": "Parte Principal",
        "duracion_min": 70,
        "descripcion": "Ejercicios de finalización"
      },
      {
        "nombre": "Vuelta a la calma",
        "duracion_min": 30,
        "descripcion": "Hidratación y retroalimentación"
      }
    ],
    "entrenador": "Mónica Ruiz"
  },
  {
    "id_entrenamiento_mysql": 5,
    "categoria": "Sub-15",
    "objetivo_sesion": "Mejorar resistencia aeróbica",
    "duracion_total_min": 120,
    "materiales": [
      "Bandas elásticas",
      "Vallas",
      "Cronómetro",
      "Arcos pequeños",
      "Balones"
    ],
    "fases": [
      {
        "nombre": "Calentamiento",
        "duracion_min": 20,
        "descripcion": "Skipping y cambios de ritmo"
      },
      {
        "nombre": "Parte Principal",
        "duracion_min": 70,
        "descripcion": "Partido reducido 5v5"
      },
      {
        "nombre": "Vuelta a la calma",
        "duracion_min": 30,
        "descripcion": "Ejercicios de respiración"
      }
    ],
    "entrenador": "Mónica Ruiz"
  },
  {
    "id_entrenamiento_mysql": 6,
    "categoria": "Sub-15",
    "objetivo_sesion": "Reforzar comunicación en defensa",
    "duracion_total_min": 120,
    "materiales": [
      "Cronómetro",
      "Conos",
      "Escaleras de coordinación",
      "Petos"
    ],
    "fases": [
      {
        "nombre": "Calentamiento",
        "duracion_min": 20,
        "descripcion": "Rondos de activación"
      },
      {
        "nombre": "Parte Principal",
        "duracion_min": 70,
        "descripcion": "Posicionamiento defensivo 4-4-2"
      },
      {
        "nombre": "Vuelta a la calma",
        "duracion_min": 30,
        "descripcion": "Charla técnica grupal"
      }
    ],
    "entrenador": "Mónica Ruiz"
  }
]
);

// ── 2. ESTADÍSTICAS POR ENTRENAMIENTO ───────────────────────
db.estadisticas_jugador.insertMany(
[
  {
    "id_entrenamiento_mysql": 1,
    "jugadores": [
      {
        "identificacion_jugador": "123978249",
        "nombre": "Cristian Ospina López",
        "distancia_km": 9.5,
        "sprints": 15,
        "nota": 8.5
      },
      {
        "identificacion_jugador": "165579548",
        "nombre": "Santiago López Ospina",
        "distancia_km": 6.2,
        "sprints": 14,
        "nota": 6.2
      },
      {
        "identificacion_jugador": "132138745",
        "nombre": "Andrés Ramírez Salcedo",
        "distancia_km": 5.3,
        "sprints": 23,
        "nota": 8.3
      },
      {
        "identificacion_jugador": "111496211",
        "nombre": "Brayan Ruiz Muñoz",
        "distancia_km": 9.2,
        "sprints": 22,
        "nota": 7.4
      },
      {
        "identificacion_jugador": "116879290",
        "nombre": "Sebastián Rojas Ruiz",
        "distancia_km": 8.5,
        "sprints": 14,
        "nota": 8.7
      },
      {
        "identificacion_jugador": "172383095",
        "nombre": "Omar Reyes Silva",
        "distancia_km": 7.1,
        "sprints": 20,
        "nota": 6.6
      },
      {
        "identificacion_jugador": "153551839",
        "nombre": "Diego Medina Mora",
        "distancia_km": 8.6,
        "sprints": 8,
        "nota": 9.5
      },
      {
        "identificacion_jugador": "160597444",
        "nombre": "Camilo Ramírez Ramírez",
        "distancia_km": 9.7,
        "sprints": 11,
        "nota": 9.0
      },
      {
        "identificacion_jugador": "178961459",
        "nombre": "Kevin Ramírez Jiménez",
        "distancia_km": 6.2,
        "sprints": 24,
        "nota": 7.6
      },
      {
        "identificacion_jugador": "195004803",
        "nombre": "Carlos Rodríguez Ramírez",
        "distancia_km": 8.1,
        "sprints": 11,
        "nota": 7.6
      },
      {
        "identificacion_jugador": "144349361",
        "nombre": "Juan Pablo Díaz Ramírez",
        "distancia_km": 9.4,
        "sprints": 24,
        "nota": 9.9
      },
      {
        "identificacion_jugador": "128754377",
        "nombre": "Kevin González Reyes",
        "distancia_km": 8.3,
        "sprints": 22,
        "nota": 8.3
      },
      {
        "identificacion_jugador": "132614537",
        "nombre": "Esteban Valencia Castro",
        "distancia_km": 9.0,
        "sprints": 24,
        "nota": 7.4
      },
      {
        "identificacion_jugador": "188447167",
        "nombre": "Tomás Mora Castro",
        "distancia_km": 10.0,
        "sprints": 22,
        "nota": 9.5
      },
      {
        "identificacion_jugador": "190377459",
        "nombre": "Carlos Medina López",
        "distancia_km": 9.1,
        "sprints": 23,
        "nota": 7.5
      },
      {
        "identificacion_jugador": "114665841",
        "nombre": "David Sánchez Sánchez",
        "distancia_km": 9.1,
        "sprints": 16,
        "nota": 8.9
      },
      {
        "identificacion_jugador": "156623995",
        "nombre": "Felipe Torres Ortiz",
        "distancia_km": 7.9,
        "sprints": 15,
        "nota": 6.7
      },
      {
        "identificacion_jugador": "159476001",
        "nombre": "Kevin López Rodríguez",
        "distancia_km": 5.4,
        "sprints": 17,
        "nota": 6.6
      },
      {
        "identificacion_jugador": "164606833",
        "nombre": "Daniel Morales Vargas",
        "distancia_km": 6.8,
        "sprints": 25,
        "nota": 5.9
      },
      {
        "identificacion_jugador": "150864911",
        "nombre": "Santiago Vargas Torres",
        "distancia_km": 5.8,
        "sprints": 20,
        "nota": 8.6
      }
    ],
    "count": 20
  },
  {
    "id_entrenamiento_mysql": 2,
    "jugadores": [
      {
        "identificacion_jugador": "100435578",
        "nombre": "Brayan Salcedo Reyes",
        "distancia_km": 10.2,
        "sprints": 8,
        "nota": 9.4
      },
      {
        "identificacion_jugador": "123978249",
        "nombre": "Cristian Ospina López",
        "distancia_km": 9.2,
        "sprints": 20,
        "nota": 7.6
      },
      {
        "identificacion_jugador": "185758349",
        "nombre": "Cristian Herrera Sánchez",
        "distancia_km": 10.2,
        "sprints": 17,
        "nota": 8.9
      },
      {
        "identificacion_jugador": "172394227",
        "nombre": "Omar Ospina Díaz",
        "distancia_km": 9.7,
        "sprints": 21,
        "nota": 7.9
      },
      {
        "identificacion_jugador": "165579548",
        "nombre": "Santiago López Ospina",
        "distancia_km": 9.0,
        "sprints": 15,
        "nota": 7.7
      },
      {
        "identificacion_jugador": "132138745",
        "nombre": "Andrés Ramírez Salcedo",
        "distancia_km": 6.5,
        "sprints": 23,
        "nota": 5.6
      },
      {
        "identificacion_jugador": "111496211",
        "nombre": "Brayan Ruiz Muñoz",
        "distancia_km": 6.8,
        "sprints": 20,
        "nota": 8.8
      },
      {
        "identificacion_jugador": "116879290",
        "nombre": "Sebastián Rojas Ruiz",
        "distancia_km": 9.6,
        "sprints": 12,
        "nota": 9.9
      },
      {
        "identificacion_jugador": "135575298",
        "nombre": "Cristian Morales Herrera",
        "distancia_km": 7.9,
        "sprints": 20,
        "nota": 8.2
      },
      {
        "identificacion_jugador": "172383095",
        "nombre": "Omar Reyes Silva",
        "distancia_km": 8.6,
        "sprints": 10,
        "nota": 8.4
      },
      {
        "identificacion_jugador": "153551839",
        "nombre": "Diego Medina Mora",
        "distancia_km": 5.7,
        "sprints": 22,
        "nota": 6.3
      },
      {
        "identificacion_jugador": "160597444",
        "nombre": "Camilo Ramírez Ramírez",
        "distancia_km": 6.4,
        "sprints": 18,
        "nota": 6.5
      },
      {
        "identificacion_jugador": "195004803",
        "nombre": "Carlos Rodríguez Ramírez",
        "distancia_km": 6.8,
        "sprints": 20,
        "nota": 6.8
      },
      {
        "identificacion_jugador": "144349361",
        "nombre": "Juan Pablo Díaz Ramírez",
        "distancia_km": 10.2,
        "sprints": 21,
        "nota": 6.6
      },
      {
        "identificacion_jugador": "128754377",
        "nombre": "Kevin González Reyes",
        "distancia_km": 5.5,
        "sprints": 8,
        "nota": 8.9
      },
      {
        "identificacion_jugador": "190377459",
        "nombre": "Carlos Medina López",
        "distancia_km": 5.3,
        "sprints": 19,
        "nota": 6.5
      },
      {
        "identificacion_jugador": "156623995",
        "nombre": "Felipe Torres Ortiz",
        "distancia_km": 5.4,
        "sprints": 9,
        "nota": 8.9
      },
      {
        "identificacion_jugador": "159476001",
        "nombre": "Kevin López Rodríguez",
        "distancia_km": 10.2,
        "sprints": 14,
        "nota": 9.3
      },
      {
        "identificacion_jugador": "112517517",
        "nombre": "Omar Morales Ramírez",
        "distancia_km": 8.4,
        "sprints": 15,
        "nota": 6.1
      },
      {
        "identificacion_jugador": "164606833",
        "nombre": "Daniel Morales Vargas",
        "distancia_km": 8.7,
        "sprints": 14,
        "nota": 7.6
      },
      {
        "identificacion_jugador": "150864911",
        "nombre": "Santiago Vargas Torres",
        "distancia_km": 6.4,
        "sprints": 19,
        "nota": 6.3
      }
    ],
    "count": 21
  },
  {
    "id_entrenamiento_mysql": 3,
    "jugadores": [
      {
        "identificacion_jugador": "100435578",
        "nombre": "Brayan Salcedo Reyes",
        "distancia_km": 5.6,
        "sprints": 17,
        "nota": 9.3
      },
      {
        "identificacion_jugador": "123978249",
        "nombre": "Cristian Ospina López",
        "distancia_km": 8.3,
        "sprints": 11,
        "nota": 9.1
      },
      {
        "identificacion_jugador": "185758349",
        "nombre": "Cristian Herrera Sánchez",
        "distancia_km": 8.1,
        "sprints": 9,
        "nota": 7.1
      },
      {
        "identificacion_jugador": "165579548",
        "nombre": "Santiago López Ospina",
        "distancia_km": 7.4,
        "sprints": 19,
        "nota": 5.8
      },
      {
        "identificacion_jugador": "132138745",
        "nombre": "Andrés Ramírez Salcedo",
        "distancia_km": 8.6,
        "sprints": 8,
        "nota": 9.3
      },
      {
        "identificacion_jugador": "111496211",
        "nombre": "Brayan Ruiz Muñoz",
        "distancia_km": 9.5,
        "sprints": 11,
        "nota": 7.5
      },
      {
        "identificacion_jugador": "116879290",
        "nombre": "Sebastián Rojas Ruiz",
        "distancia_km": 7.0,
        "sprints": 22,
        "nota": 8.7
      },
      {
        "identificacion_jugador": "172383095",
        "nombre": "Omar Reyes Silva",
        "distancia_km": 7.4,
        "sprints": 24,
        "nota": 9.8
      },
      {
        "identificacion_jugador": "153551839",
        "nombre": "Diego Medina Mora",
        "distancia_km": 6.5,
        "sprints": 25,
        "nota": 9.0
      },
      {
        "identificacion_jugador": "160597444",
        "nombre": "Camilo Ramírez Ramírez",
        "distancia_km": 7.6,
        "sprints": 16,
        "nota": 7.0
      },
      {
        "identificacion_jugador": "178961459",
        "nombre": "Kevin Ramírez Jiménez",
        "distancia_km": 6.4,
        "sprints": 10,
        "nota": 6.8
      },
      {
        "identificacion_jugador": "195004803",
        "nombre": "Carlos Rodríguez Ramírez",
        "distancia_km": 7.5,
        "sprints": 22,
        "nota": 8.1
      },
      {
        "identificacion_jugador": "132614537",
        "nombre": "Esteban Valencia Castro",
        "distancia_km": 8.7,
        "sprints": 18,
        "nota": 5.6
      },
      {
        "identificacion_jugador": "188447167",
        "nombre": "Tomás Mora Castro",
        "distancia_km": 9.7,
        "sprints": 13,
        "nota": 7.7
      },
      {
        "identificacion_jugador": "190377459",
        "nombre": "Carlos Medina López",
        "distancia_km": 7.0,
        "sprints": 16,
        "nota": 7.0
      },
      {
        "identificacion_jugador": "114665841",
        "nombre": "David Sánchez Sánchez",
        "distancia_km": 9.8,
        "sprints": 16,
        "nota": 8.0
      },
      {
        "identificacion_jugador": "156623995",
        "nombre": "Felipe Torres Ortiz",
        "distancia_km": 7.8,
        "sprints": 14,
        "nota": 5.9
      },
      {
        "identificacion_jugador": "159476001",
        "nombre": "Kevin López Rodríguez",
        "distancia_km": 9.0,
        "sprints": 23,
        "nota": 8.0
      },
      {
        "identificacion_jugador": "150864911",
        "nombre": "Santiago Vargas Torres",
        "distancia_km": 6.3,
        "sprints": 23,
        "nota": 8.4
      }
    ],
    "count": 19
  },
  {
    "id_entrenamiento_mysql": 4,
    "jugadores": [
      {
        "identificacion_jugador": "103356886",
        "nombre": "Brayan Torres Ramírez",
        "distancia_km": 6.9,
        "sprints": 25,
        "nota": 7.0
      },
      {
        "identificacion_jugador": "190825067",
        "nombre": "Brayan Salcedo Suárez",
        "distancia_km": 8.9,
        "sprints": 16,
        "nota": 6.9
      },
      {
        "identificacion_jugador": "104265799",
        "nombre": "Santiago Martínez Sánchez",
        "distancia_km": 6.3,
        "sprints": 14,
        "nota": 6.9
      },
      {
        "identificacion_jugador": "181030736",
        "nombre": "Miguel Valencia Rodríguez",
        "distancia_km": 9.1,
        "sprints": 13,
        "nota": 6.4
      },
      {
        "identificacion_jugador": "138840994",
        "nombre": "Juan Pablo Morales Ramírez",
        "distancia_km": 9.1,
        "sprints": 16,
        "nota": 8.8
      },
      {
        "identificacion_jugador": "147683626",
        "nombre": "Daniel Rojas Torres",
        "distancia_km": 10.4,
        "sprints": 24,
        "nota": 8.2
      },
      {
        "identificacion_jugador": "181756179",
        "nombre": "Carlos Pérez Suárez",
        "distancia_km": 10.4,
        "sprints": 14,
        "nota": 6.8
      },
      {
        "identificacion_jugador": "162043515",
        "nombre": "Samuel Torres Ospina",
        "distancia_km": 7.0,
        "sprints": 17,
        "nota": 5.6
      },
      {
        "identificacion_jugador": "191887369",
        "nombre": "Nicolás Muñoz Cruz",
        "distancia_km": 7.9,
        "sprints": 16,
        "nota": 5.7
      },
      {
        "identificacion_jugador": "128538251",
        "nombre": "Carlos Ruiz Vargas",
        "distancia_km": 5.3,
        "sprints": 17,
        "nota": 8.6
      },
      {
        "identificacion_jugador": "178461803",
        "nombre": "Tomás Salcedo Jiménez",
        "distancia_km": 5.7,
        "sprints": 23,
        "nota": 6.0
      },
      {
        "identificacion_jugador": "118566572",
        "nombre": "Cristian Ruiz Martínez",
        "distancia_km": 5.1,
        "sprints": 17,
        "nota": 7.6
      },
      {
        "identificacion_jugador": "120514014",
        "nombre": "Carlos Pérez Valencia",
        "distancia_km": 7.4,
        "sprints": 13,
        "nota": 9.8
      },
      {
        "identificacion_jugador": "151642594",
        "nombre": "Samuel Herrera Ortiz",
        "distancia_km": 6.4,
        "sprints": 23,
        "nota": 6.0
      },
      {
        "identificacion_jugador": "191306093",
        "nombre": "Brayan López Rojas",
        "distancia_km": 5.4,
        "sprints": 23,
        "nota": 5.8
      }
    ],
    "count": 15
  },
  {
    "id_entrenamiento_mysql": 5,
    "jugadores": [
      {
        "identificacion_jugador": "103356886",
        "nombre": "Brayan Torres Ramírez",
        "distancia_km": 10.0,
        "sprints": 17,
        "nota": 9.4
      },
      {
        "identificacion_jugador": "190825067",
        "nombre": "Brayan Salcedo Suárez",
        "distancia_km": 10.4,
        "sprints": 17,
        "nota": 8.1
      },
      {
        "identificacion_jugador": "175329037",
        "nombre": "Daniel Silva Medina",
        "distancia_km": 5.3,
        "sprints": 11,
        "nota": 9.8
      },
      {
        "identificacion_jugador": "129587039",
        "nombre": "Julián Jiménez Torres",
        "distancia_km": 6.1,
        "sprints": 14,
        "nota": 6.7
      },
      {
        "identificacion_jugador": "145176955",
        "nombre": "Camilo Martínez Vargas",
        "distancia_km": 5.4,
        "sprints": 15,
        "nota": 6.3
      },
      {
        "identificacion_jugador": "150806024",
        "nombre": "Juan Pablo Suárez Flores",
        "distancia_km": 5.4,
        "sprints": 8,
        "nota": 7.3
      },
      {
        "identificacion_jugador": "177490893",
        "nombre": "Daniel Silva Martínez",
        "distancia_km": 8.8,
        "sprints": 23,
        "nota": 6.8
      },
      {
        "identificacion_jugador": "138840994",
        "nombre": "Juan Pablo Morales Ramírez",
        "distancia_km": 6.3,
        "sprints": 17,
        "nota": 8.7
      },
      {
        "identificacion_jugador": "147683626",
        "nombre": "Daniel Rojas Torres",
        "distancia_km": 7.5,
        "sprints": 15,
        "nota": 9.7
      },
      {
        "identificacion_jugador": "181756179",
        "nombre": "Carlos Pérez Suárez",
        "distancia_km": 9.3,
        "sprints": 14,
        "nota": 7.4
      },
      {
        "identificacion_jugador": "162043515",
        "nombre": "Samuel Torres Ospina",
        "distancia_km": 8.0,
        "sprints": 12,
        "nota": 9.6
      },
      {
        "identificacion_jugador": "191887369",
        "nombre": "Nicolás Muñoz Cruz",
        "distancia_km": 9.5,
        "sprints": 10,
        "nota": 5.8
      },
      {
        "identificacion_jugador": "104308421",
        "nombre": "Nicolás Vargas Torres",
        "distancia_km": 9.4,
        "sprints": 17,
        "nota": 7.5
      },
      {
        "identificacion_jugador": "128538251",
        "nombre": "Carlos Ruiz Vargas",
        "distancia_km": 7.6,
        "sprints": 17,
        "nota": 8.6
      },
      {
        "identificacion_jugador": "119175900",
        "nombre": "Miguel González Ramírez",
        "distancia_km": 10.2,
        "sprints": 24,
        "nota": 7.9
      },
      {
        "identificacion_jugador": "118566572",
        "nombre": "Cristian Ruiz Martínez",
        "distancia_km": 7.4,
        "sprints": 9,
        "nota": 9.5
      },
      {
        "identificacion_jugador": "151642594",
        "nombre": "Samuel Herrera Ortiz",
        "distancia_km": 9.0,
        "sprints": 16,
        "nota": 5.6
      },
      {
        "identificacion_jugador": "191306093",
        "nombre": "Brayan López Rojas",
        "distancia_km": 6.3,
        "sprints": 8,
        "nota": 10.0
      },
      {
        "identificacion_jugador": "186028436",
        "nombre": "Nicolás López Flores",
        "distancia_km": 8.7,
        "sprints": 16,
        "nota": 8.1
      }
    ],
    "count": 19
  },
  {
    "id_entrenamiento_mysql": 6,
    "jugadores": [
      {
        "identificacion_jugador": "103356886",
        "nombre": "Brayan Torres Ramírez",
        "distancia_km": 8.7,
        "sprints": 13,
        "nota": 7.0
      },
      {
        "identificacion_jugador": "190825067",
        "nombre": "Brayan Salcedo Suárez",
        "distancia_km": 8.8,
        "sprints": 17,
        "nota": 8.5
      },
      {
        "identificacion_jugador": "104265799",
        "nombre": "Santiago Martínez Sánchez",
        "distancia_km": 7.2,
        "sprints": 25,
        "nota": 5.7
      },
      {
        "identificacion_jugador": "129587039",
        "nombre": "Julián Jiménez Torres",
        "distancia_km": 5.5,
        "sprints": 16,
        "nota": 7.0
      },
      {
        "identificacion_jugador": "121429110",
        "nombre": "Yeison Castro Ríos",
        "distancia_km": 10.3,
        "sprints": 20,
        "nota": 9.4
      },
      {
        "identificacion_jugador": "145176955",
        "nombre": "Camilo Martínez Vargas",
        "distancia_km": 9.5,
        "sprints": 8,
        "nota": 8.5
      },
      {
        "identificacion_jugador": "181030736",
        "nombre": "Miguel Valencia Rodríguez",
        "distancia_km": 8.0,
        "sprints": 21,
        "nota": 5.7
      },
      {
        "identificacion_jugador": "150806024",
        "nombre": "Juan Pablo Suárez Flores",
        "distancia_km": 7.9,
        "sprints": 23,
        "nota": 8.3
      },
      {
        "identificacion_jugador": "177490893",
        "nombre": "Daniel Silva Martínez",
        "distancia_km": 9.2,
        "sprints": 14,
        "nota": 6.7
      },
      {
        "identificacion_jugador": "138840994",
        "nombre": "Juan Pablo Morales Ramírez",
        "distancia_km": 5.7,
        "sprints": 17,
        "nota": 7.5
      },
      {
        "identificacion_jugador": "137308985",
        "nombre": "Julián Medina Muñoz",
        "distancia_km": 8.8,
        "sprints": 11,
        "nota": 5.6
      },
      {
        "identificacion_jugador": "147683626",
        "nombre": "Daniel Rojas Torres",
        "distancia_km": 8.5,
        "sprints": 15,
        "nota": 8.7
      },
      {
        "identificacion_jugador": "181756179",
        "nombre": "Carlos Pérez Suárez",
        "distancia_km": 6.7,
        "sprints": 8,
        "nota": 8.0
      },
      {
        "identificacion_jugador": "162043515",
        "nombre": "Samuel Torres Ospina",
        "distancia_km": 5.5,
        "sprints": 11,
        "nota": 7.6
      },
      {
        "identificacion_jugador": "191887369",
        "nombre": "Nicolás Muñoz Cruz",
        "distancia_km": 5.6,
        "sprints": 12,
        "nota": 7.7
      },
      {
        "identificacion_jugador": "128538251",
        "nombre": "Carlos Ruiz Vargas",
        "distancia_km": 8.9,
        "sprints": 24,
        "nota": 8.7
      },
      {
        "identificacion_jugador": "119175900",
        "nombre": "Miguel González Ramírez",
        "distancia_km": 7.3,
        "sprints": 23,
        "nota": 9.9
      },
      {
        "identificacion_jugador": "178461803",
        "nombre": "Tomás Salcedo Jiménez",
        "distancia_km": 6.3,
        "sprints": 25,
        "nota": 6.2
      },
      {
        "identificacion_jugador": "118566572",
        "nombre": "Cristian Ruiz Martínez",
        "distancia_km": 6.0,
        "sprints": 24,
        "nota": 8.9
      },
      {
        "identificacion_jugador": "120514014",
        "nombre": "Carlos Pérez Valencia",
        "distancia_km": 5.8,
        "sprints": 10,
        "nota": 6.7
      },
      {
        "identificacion_jugador": "151642594",
        "nombre": "Samuel Herrera Ortiz",
        "distancia_km": 9.3,
        "sprints": 21,
        "nota": 7.0
      },
      {
        "identificacion_jugador": "191306093",
        "nombre": "Brayan López Rojas",
        "distancia_km": 9.3,
        "sprints": 16,
        "nota": 9.2
      },
      {
        "identificacion_jugador": "186028436",
        "nombre": "Nicolás López Flores",
        "distancia_km": 6.6,
        "sprints": 17,
        "nota": 9.3
      }
    ],
    "count": 23
  }
]
);

// ── 3. OBSERVACIONES DE SESIÓN ──────────────────────────────
db.observaciones_sesion.insertMany(
[
  {
    "id_entrenamiento": 1,
    "observacion_general": "Sesión de tipo Táctico para Sub-17. El grupo trabajó con buena disposición. Se alcanzaron los objetivos planteados.",
    "aspectos_positivos": [
      "Buena actitud",
      "Alta intensidad"
    ],
    "aspectos_a_mejorar": [
      "Velocidad de transición",
      "Posicionamiento en pelota parada"
    ],
    "estado_animo_grupo": "regular",
    "condiciones_clima": "parcialmente nublado"
  },
  {
    "id_entrenamiento": 2,
    "observacion_general": "Sesión de tipo Físico para Sub-17. El grupo trabajó con buena disposición. Se alcanzaron los objetivos planteados.",
    "aspectos_positivos": [
      "Trabajo en equipo destacado",
      "Alta intensidad"
    ],
    "aspectos_a_mejorar": [
      "Comunicación verbal",
      "Primer toque bajo presión"
    ],
    "estado_animo_grupo": "motivado",
    "condiciones_clima": "soleado"
  },
  {
    "id_entrenamiento": 3,
    "observacion_general": "Sesión de tipo Físico para Sub-17. El grupo trabajó con buena disposición. Se alcanzaron los objetivos planteados.",
    "aspectos_positivos": [
      "Rápida asimilación de instrucciones",
      "Trabajo en equipo destacado"
    ],
    "aspectos_a_mejorar": [
      "Concentración en segunda mitad",
      "Posicionamiento en pelota parada"
    ],
    "estado_animo_grupo": "regular",
    "condiciones_clima": "nublado"
  },
  {
    "id_entrenamiento": 4,
    "observacion_general": "Sesión de tipo Táctico para Sub-15. El grupo trabajó con buena disposición. Se alcanzaron los objetivos planteados.",
    "aspectos_positivos": [
      "Alta intensidad",
      "Buena actitud"
    ],
    "aspectos_a_mejorar": [
      "Comunicación verbal",
      "Primer toque bajo presión"
    ],
    "estado_animo_grupo": "motivado",
    "condiciones_clima": "nublado"
  },
  {
    "id_entrenamiento": 5,
    "observacion_general": "Sesión de tipo Físico para Sub-15. El grupo trabajó con buena disposición. Se alcanzaron los objetivos planteados.",
    "aspectos_positivos": [
      "Buena actitud",
      "Rápida asimilación de instrucciones"
    ],
    "aspectos_a_mejorar": [
      "Posicionamiento en pelota parada",
      "Velocidad de transición"
    ],
    "estado_animo_grupo": "regular",
    "condiciones_clima": "nublado"
  },
  {
    "id_entrenamiento": 6,
    "observacion_general": "Sesión de tipo Mixto para Sub-15. El grupo trabajó con buena disposición. Se alcanzaron los objetivos planteados.",
    "aspectos_positivos": [
      "Trabajo en equipo destacado",
      "Rápida asimilación de instrucciones"
    ],
    "aspectos_a_mejorar": [
      "Comunicación verbal",
      "Velocidad de transición"
    ],
    "estado_animo_grupo": "muy motivado",
    "condiciones_clima": "lluvioso"
  }
]
);

print('✅  Seed completado: 6 planes, 6 estadísticas, 6 observaciones');