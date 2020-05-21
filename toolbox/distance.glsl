#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURFACE_DIST 0.01

float sdSphere(vec3 p, float radius)
{
    return length(p) - radius;
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float radius)
{
    vec3 ab = b - a;
    vec3 ap = p - a;

    // Ratio distance along a line segment connecting the two centers
    float t = dot(ab, ap) / dot(ab, ab);
    t = clamp(t, 0.0, 1.0);
    // Point along the line segment connecting the two centers
    vec3 c = a + t*ab;

    return length(p - c) - radius;
}

float get_dist(vec3 p)
{
    // Distance to ground plane - this assumes a flat axis-aligned plane
    float d = p.y;
    d = min(d, sdSphere(p-vec3(0, 0.5, 5), 0.5));
    d = min(d, sdCapsule(p-vec3(-2.5, 0.5, 4.5), vec3(0), vec3(1), 0.3));

    return d;
}

float ray_march(vec3 ray_origin, vec3 ray_direction)
{
    float dist_origin = 0.0;

    for (int i=0; i < MAX_STEPS; i++)
    {
        vec3 pos = ray_origin + ray_direction*dist_origin;
        float dist_scene = get_dist(pos);
        dist_origin += dist_scene;
        if (dist_origin > MAX_DIST || dist_scene < SURFACE_DIST)
        {
            break;
        }
    }

    return dist_origin;
}

vec3 get_normal(vec3 p)
{
    float d = get_dist(p);
    vec2 e = vec2(0.01, 0.0);
    vec3 n = d - vec3(
        get_dist(p-e.xyy),
        get_dist(p-e.yxy),
        get_dist(p-e.yyx)
    );

    return normalize(n);
}

// Diffuse lighting
float get_light(vec3 p)
{
    vec3 light_pos = vec3(0, 5, 6);
    light_pos.xz += vec2(sin(iTime), cos(iTime))*2.0;
    vec3 light_vector = normalize(light_pos - p);
    vec3 normal = get_normal(p);

    float dif = clamp(dot(normal, light_vector), 0.0, 1.0);
    // Shadow - march along the light vector
    // Move away from the surface by a bit to avoid triggering SURFACE_DIST
    float d = ray_march(p+normal*SURFACE_DIST*2.0, light_vector);
    // If the distance marched was less than the distance to the light,
    // somthing is occluding the light
    if (d < length(light_pos - p))
    {
        dif *= 0.1;
    }

    return dif;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord/iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;
    vec3 col = vec3(0.0);

    // Position of camera - "Ray origin"
    vec3 ro = vec3(0, 1.5, 0);
    // Ray direction
    vec3 rd = normalize(vec3(uv.x, uv.y, 1.0));

    float d = ray_march(ro, rd);
    vec3 p = ro + rd * d;
    // Diffuse lighting
    float dif = get_light(p);
    //col = get_normal(p);
    col = vec3(dif);

    fragColor = vec4(col, 1.0);
}
