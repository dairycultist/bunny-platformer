shader_type canvas_item;

void fragment() {
	
	vec2 quantized_uv = floor(UV * 64.0) / 64.0;
	vec2 centered_uv = (quantized_uv - 0.5) * 2.0;
	float dist = length(centered_uv);
	float warp1 = texture(TEXTURE, quantized_uv + vec2(TIME * 0.1, 0.0)).x * 0.13;
	float warp2 = texture(TEXTURE, (quantized_uv + TIME * 0.1) * 2.0).x * 0.2 + sin(TIME + atan(centered_uv.y, centered_uv.x) * 5.0) * 0.1;
	
	float fac1 = step(0.5, dist + warp1);
	float fac2 = step(0.9, dist + warp2);
	
	vec4 event_horizon_color = mix(vec4(1.0), vec4(1.0, 0.2, 0.0, 1.0), floor(smoothstep(0.3, 0.8, dist + warp2) * 3.0) / 3.0);
	
	COLOR = mix(mix(vec4(0.0, 0.0, 0.0, 1.0), event_horizon_color, fac1), vec4(0.0, 0.0, 0.0, 0.0), fac2);
}