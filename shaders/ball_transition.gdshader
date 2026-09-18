shader_type canvas_item;

uniform bool ativo = false;
uniform float lado = 1.0;
uniform vec2 ponto_corte;
uniform vec2 normal_corte = vec2(1.0, 0.0);

varying vec2 pos_mundo;

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	if (ativo && dot(pos_mundo - ponto_corte, normal_corte) * lado < 0.0) {
		discard;
	}
}