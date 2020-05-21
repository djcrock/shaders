// From tutorial
// https://www.youtube.com/watch?v=ZlNnrpM0TRg

#define s(a, b, t) smoothstep(a, b, t)
#define sat(x) clamp(x, 0.0, 1.0)

float remap01(float a, float b, float t)
{
    return sat((t-a) / (b-a));
}

float remap(float a, float b, float c, float d, float t)
{
    return sat((t-a) / (b-a)) * (d-c) + c;
}

vec2 within(vec2 uv, vec4 rect)
{
    return (uv-rect.xy) / (rect.zw-rect.xy);
}

vec4 eye(vec2 uv)
{
    uv -= 0.5;
    float d = length(uv);

    vec4 iris_col = vec4(0.3, 0.5, 1.0, 1.0);
    vec4 col = mix(vec4(1.0), iris_col, s(0.1, 0.7, d)*0.5);
    
    // Inset shadow
    col.rgb *= 1.0 - s(0.45, 0.5, d) * 0.5 * sat(-uv.y - uv.x);

    // Iris outline
    col.rgb = mix(col.rgb, vec3(0.0), s(0.3, 0.28, d));
    // Iris
    iris_col *= 1.0 + s(0.3, 0.05, d);
    col.rgb = mix(col.rgb, iris_col.rgb, s(0.28, 0.25, d));
    // Pupil
    col.rgb = mix(col.rgb, vec3(0.0), s(0.16, 0.14, d));

    float highlight = s(0.1, 0.09, length(uv - vec2(-0.15, 0.15)));
    highlight += s(0.07, 0.05, length(uv + vec2(-0.08, 0.08)));
    col.rgb = mix(col.rgb, vec3(1.0), highlight);

    col.a = s(0.5, 0.48, d);
    return col;
}

vec4 mouth(vec2 uv)
{
    uv -= 0.5;
    vec4 col = vec4(0.5, 0.18, 0.05, 1.0);

    uv.y *= 1.5;
    uv.y -= uv.x * uv.x * 2.0;
    float d = length(uv);
    col.a = s(0.5, 0.48, d);
    
    float teeth_d = length (uv - vec2(0.0, 0.6));
    vec3 tooth_col = vec3(1.0) * s(0.6, 0.35, d);
    col.rgb = mix(col.rgb, tooth_col, s(0.4, 0.37, teeth_d));

    float tongue_d = length(uv + vec2(0.0, 0.5));
    col.rgb = mix(col.rgb, vec3(1.0, 0.5, 0.5), s(0.5, 0.2, tongue_d));

    return col;
}

vec4 head(vec2 uv)
{
    vec4 col = vec4(0.9, 0.65, 0.1, 1.0);

    float d = length(uv);
    col.a = s(0.5, 0.49, d);

    float edge_shade = remap01(0.35, 0.5, d);
    edge_shade *= edge_shade;
    col.rgb *= 1.0 - edge_shade*0.5;

    // Border
    col.rgb = mix(col.rgb, vec3(0.6, 0.3, 0.1), s(0.47, 0.48, d));

    float highlight = s(0.41, 0.405, d);
    highlight *= remap(.41, -0.1, 0.75, 0.0, uv.y);
    col.rgb = mix(col.rgb, vec3(1.0), highlight);

    d = length (uv - vec2(0.25, -0.2));
    float cheek = s(0.2, 0.01, d) * 0.4;
    // Don't fall all the way off; give a bit of "edge"
    cheek *= s(0.17, 0.16, d);
    col.rgb = mix(col.rgb, vec3(1.0, 0.1, 0.1), cheek);

    return col;
}

vec4 smiley(vec2 uv)
{
    vec4 col = vec4(0.0);

    // Mirror the x axis
    // Anything shown in +ve x will also appear in -ve x
    uv.x = abs(uv.x);
    vec4 head = head(uv);
    vec4 eye = eye(within(uv, vec4(0.03, -0.1, 0.37, 0.25)));
    vec4 mouth = mouth(within(uv, vec4(-0.3, -0.4, 0.3, -0.1)));

    col = mix(col, head, head.a);
    col = mix(col, eye, eye.a);
    col = mix(col, mouth, mouth.a);
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord/iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;

    fragColor = smiley(uv);
}
