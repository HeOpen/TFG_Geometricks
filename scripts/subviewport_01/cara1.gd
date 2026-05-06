extends Node2D

# =============================================================
# CARA 1 - Primera cara del cubo (verde)
# =============================================================
# Esta escena hereda de CaraBase.tscn, que ya tiene el fondo (ColorRect).
# Aquí añadimos el contenido jugable: suelo, plataformas, obstáculos, etc.
#
# ESTRUCTURA DE NODOS:
#   Cara1 (Node2D)
#   ├── ColorRect       ← fondo heredado de CaraBase (no tocar)
#   ├── Suelo           ← StaticBody2D: superficie base donde cae el jugador
#   │   ├── Visual      ← ColorRect que dibuja el suelo visualmente
#   │   └── Colision    ← CollisionShape2D (rectángulo de 1152 x 20 px)
#   └── Plataforma1     ← StaticBody2D: plataforma flotante de ejemplo
#       ├── Visual      ← ColorRect que dibuja la plataforma visualmente
#       └── Colision    ← CollisionShape2D (rectángulo de 300 x 20 px)
#
# COORDENADAS DE ESTA CARA (en píxeles dentro del mundo 2D):
#   Ancho: x = 0 → 1152
#   Alto:  y = 0 → 648
#   (0,0) es la esquina superior izquierda de la cara
#
# TRANSICIONES A OTRAS CARAS:
#   El jugador sale por y < 0    → llega a cara5 (tapa superior, amarilla)
#   El jugador sale por y > 648  → llega a cara6 (tapa inferior, naranja)
#   El jugador sale por x < 0   → llega a cara3 (lateral izquierda, azul)
#   El jugador sale por x > 1152 → llega a cara2 (lateral derecha, roja)
#
# PARA AÑADIR MÁS PLATAFORMAS:
#   1. Duplica el nodo Plataforma1 en el árbol de la escena
#   2. Cámbia su posición (property "position" en el inspector)
#   3. Ajusta el tamaño del Visual (offset_right) y la Colision (shape size)
#
# PARA AÑADIR PAREDES VERTICALES:
#   Añade un StaticBody2D con CollisionShape2D de tamaño (20, 648)
#
# PARA AÑADIR UN PORTÓN O PULSADOR:
#   Instancia la escena del elemento y añádela como hijo de Cara1
# =============================================================
