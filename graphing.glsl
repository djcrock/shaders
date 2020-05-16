#define SCALE 0.1

float band(float t, float start, float end, float blur)
{
    return smoothstep(start-blur, start+blur, t) * smoothstep(end+blur, end-blur, t);
}

float line(float axis, float value)
{
    return band(axis - value, -0.005/SCALE, 0.005/SCALE, 0.001/SCALE);
}

float square_wave(float t, float duty)
{
    return clamp(ceil(fract(t) - (1.0 - duty)), 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord/iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;

    float x_motion = 0.0;
    float y_motion = 0.0;
    float time = iTime;
    float x = uv.x/SCALE + time*x_motion;
    float y = uv.y/SCALE + time*y_motion;

    vec3 col = vec3(0.0);

    // Axes
    vec3 axis_col = vec3(0.5);
    float axis_width = 0.002/SCALE;
    float x_axis = band(y, -axis_width/2.0, axis_width/2.0, 0.0001);
    float y_axis = band(x, -axis_width/2.0, axis_width/2.0, 0.0001);
    col += axis_col * max(x_axis, y_axis);
    // Divisions
    vec3 division_col = vec3(0.05);
    float division_width = 0.005/SCALE;
    float x_divisions = square_wave(x, division_width);
    float y_divisions = square_wave(y, division_width);
    col += division_col * max(x_divisions, y_divisions);

    // Square wave.
    float duty_cycle = 0.75;
    float square = square_wave(x, duty_cycle);
    col += vec3(0.0, 0.5, 0.0) * line(y, square);

    // Sine wave
    float sine = sin(x);
    col += vec3(0.5, 0.0, 0.0) * line(y, sine);

    // Cosine wave
    float cosine = 2.0*cos(x);
    col += vec3(0.0, 0.0, 0.5) * line(y, cosine);

    fragColor = vec4(col, 1.0);
}
