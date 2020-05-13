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

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord/iResolution.xy;
    float t = iTime;

    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;

    float smoke = 0.0;
    float x = uv.x;
    float y = uv.y;

    float m = sin(y*8.0 - t) * 0.2 * (y + 0.5);
    x -= m;

    float blur = remap(-0.5, 0.5, 0.01, 0.25, y);
    blur = pow(blur*3.0, 3.0);

    uv = vec2(x, y);
    smoke = band(uv.x, -0.03, 0.03, blur);

    vec3 col = vec3(0.8)*smoke;

    fragColor = vec4(col, 1.0);
}
