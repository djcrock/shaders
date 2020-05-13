float remap01(float a, float b, float t)
{
    return (t-a) / (b-a);
}

float remap(float a, float b, float c, float d, float t)
{
    return clamp(mix(c, d, remap01(a, b, t)), c, d);
}

float band(float t, float start, float end, float blur)
{
    return smoothstep(start-blur, start+blur, t) * smoothstep(end+blur, end-blur, t);
}

float rect(vec2 uv, float left, float right, float bottom, float top, float blur)
{
    return band(uv.x, left, right, blur) * band(uv.y, bottom, top, blur);
}

mat2 rotate(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat2(c, -s, s, c);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord/iResolution.xy;
    float t = iTime;

    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;

    vec2 smoke_uv = uv;
    float smoke = 0.0;

    float m = sin(smoke_uv.y*8.0 - t*0.5) * 0.2 * (smoke_uv.y + 0.4);
    smoke_uv.x -= m;
    smoke_uv.x *= clamp(4.0*(-smoke_uv.y + 0.5), 1.0, 4.0);

    float blur = remap(-0.5, 0.5, 0.01, 0.25, smoke_uv.y);
    blur = pow(blur*3.0, 3.0) + 0.01;

    smoke = rect(smoke_uv, -0.03, 0.03, -0.4, 2.0, blur);

    vec2 cig_uv = rotate(-0.25) * uv;
    cig_uv -= vec2(-0.3, -0.4);
    float cig = rect(cig_uv, -0.15, 0.39, -0.03, 0.03, 0.003);
    float butt = rect(cig_uv, -0.4, -0.15, -0.03, 0.03, 0.003);
    float ember = rect(cig_uv, 0.39, 0.4, -0.03, 0.03, 0.003);

    vec3 col = vec3(0.3)*smoke +
        vec3(0.9)*cig +
        vec3(0.7, 0.6, 0.215)*butt +
        vec3(clamp(sin(t*0.5), 0.25, 0.75), 0.0, 0.0)*ember;

    fragColor = vec4(col, 1.0);
}
