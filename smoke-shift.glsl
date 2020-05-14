float color_shift = 0.01;

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

float smoke(vec2 uv)
{
    float smoke = 0.0;
    float x = uv.x;
    float y = uv.y;

    float m = sin(y*8.0 - iTime) * 0.2 * (y + 0.5);
    x -= m;

    float blur = remap(-0.5, 0.5, 0.01, 0.25, y/2.0);
    blur = pow(blur*3.0, 3.0);

    uv = vec2(x, y);
    smoke = band(uv.x, -0.03, 0.03, blur);

    return smoke * 0.8;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord/iResolution.xy;
    float t = iTime;

    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;

    float scan = floor((sin(10.0*uv.y+iTime*1.5)+1.0005) / 2.0)/ 40.0;

    vec2 smokeuv = uv;
    smokeuv.x += round((sin(uv.y*400.0)+1.0)/2.0) / 300.0;
    smokeuv.x -= scan;

    vec3 col = vec3(
        smoke(smokeuv + vec2(-color_shift-scan/2.0, 0.0)),
        smoke(smokeuv),// + vec2(0.0, color_shift)),
        smoke(smokeuv + vec2(color_shift+scan/2.0, 0.0))
    );

    // Still band, easier to see what's going on
    // vec3 col = vec3(
    //     band(smokeuv.x -color_shift-scan/2.0, -0.03, 0.03, 0.01),
    //     band(smokeuv.x, -0.03, 0.03, 0.01),
    //     band(smokeuv.x + color_shift+scan/2.0, -0.03, 0.03, 0.01)
    // );

    // Show the scan.
    //col += band(uv.x + scan, 0.6, 0.7, 0.01);

    fragColor = vec4(col, 1.0);
}
