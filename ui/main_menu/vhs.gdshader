shader_type canvas_item;

// Variables 'uniform'. Exportan estos valores al Inspector de Godot 
// para que el diseñador de niveles pueda ajustarlos sin modificar código.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float scanline_count : hint_range(0.0, 1000.0) = 250.0;
uniform float chromatic_aberration : hint_range(0.0, 0.05) = 0.005;

// Función fragment() - Se ejecuta una vez por cada píxel de la pantalla en cada fotograma
void fragment() {
	// SCREEN_UV representa las coordenadas 2D absolutas de la pantalla (de 0.0 a 1.0)
	vec2 uv = SCREEN_UV;

	// 1. ABERRACIÓN CROMÁTICA
	// Desplazamos las coordenadas de lectura de los canales Rojo (R) y Azul (B) en el eje X
	float r = texture(screen_texture, uv + vec2(chromatic_aberration, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(chromatic_aberration, 0.0)).b;
	vec3 color = vec3(r, g, b);

	// 2. SCANLINES (Líneas de tubo catódico)
	// Generamos una onda senoidal estática multiplicada por la altura del píxel (uv.y)
	float scanline = sin(uv.y * scanline_count * 3.14159);
	// Normalizamos la onda a valores entre 0.0 y 1.0
	scanline = (scanline * 0.5) + 0.5; 
	// Oscurecemos el color final un 20% en las áreas donde cruza la onda
	color = mix(color, color * 0.8, scanline);

	// Salida final a la pantalla
	COLOR = vec4(color, 1.0);
}
