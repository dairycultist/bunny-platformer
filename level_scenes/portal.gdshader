shader_type canvas_item;

void fragment() {
	
	vec2 centered_uv = (UV - 0.5) * 2.0;
	float dist = length(centered_uv);
	float warp1 = texture(TEXTURE, UV + vec2(TIME * 0.1, 0.0)).x * 0.1;
	float warp2 = texture(TEXTURE, (UV + TIME * 0.1) * 2.0).x * 0.2 + sin(TIME + atan(centered_uv.y, centered_uv.x) * 9.0) * 0.1;
	
	float fac1 = step(0.5, dist + warp1);
	float fac2 = step(0.9, dist + warp2);
	
	COLOR = mix(mix(vec4(0.0, 0.0, 0.0, 1.0), mix(vec4(1.0), vec4(1.0, 0.3, 0.0, 1.0), smoothstep(0.6 ,1.0, dist + warp2)), fac1), vec4(0.0, 0.0, 0.0, 0.0), fac2);
}