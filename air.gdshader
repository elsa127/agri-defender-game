shader_type canvas_item;

uniform float kecepatan : hint_range(0.0, 10.0) = 3.0;
uniform float frekuensi_gelombang : hint_range(1.0, 30.0) = 15.0;
uniform float magnitudo_gelombang : hint_range(0.0, 0.5) = 0.08;

void fragment() {
    vec2 uv = UV;
    
    float gelombang = sin((uv.x + TIME * 1.5) * frekuensi_gelombang) * magnitudo_gelombang;
    uv.y += gelombang;
    
    float pergerakan = uv.x - (TIME * kecepatan);
    float pola = sin((pergerakan + uv.y) * 12.0);
    
    vec4 warna_air = vec4(0.15, 0.65, 0.95, 0.85);
    vec4 warna_busa = vec4(0.80, 0.95, 1.0, 0.95);
    
    float pinggir = smoothstep(0.0, 0.15, uv.y) * smoothstep(1.0, 0.85, uv.y);
    
    vec4 hasil_warna = mix(warna_air, warna_busa, clamp(pola, 0.0, 1.0) * 0.4);
    COLOR = hasil_warna;
    COLOR.a *= pinggir;
}