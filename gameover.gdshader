shader_type canvas_item;

uniform float p1 = 0.0;
uniform float p2 = 1.0;
uniform float p3 = 0.0;
uniform float p4 = 1.0;

float ilerp(float a, float b, float w) {
    return (w - a) / (b - a);
}

void fragment() {
    vec2 uv = UV;
    uv.x = mix(ilerp(p1, p2, uv.x), ilerp(p3, p4, uv.x), uv.y);
    if (uv.x < 0.0 || uv.x > 1.0) {
    	discard;
    }
    COLOR = texture(TEXTURE, uv);
}
