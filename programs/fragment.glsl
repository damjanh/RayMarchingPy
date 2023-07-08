#version 330
#include hg_sdf.glsl

layout(location = 0) out vec4 fragColor;

uniform vec2 u_resolution;

const float FOV = 1.0;
// Max steps of a ray
const int MAX_STEPS = 256;
// Max distance of a ray
const float MAX_DIST = 500;
// Calculation accuracy
const float EPSILON = 0.001;

vec2 fOpUnion(vec2 res1, vec2 res2) {
   return (res1.x < res2.x) ? res1 : res2;
}

vec2 map(vec3 p) {
    // plane
    float planeDist = fPlane(p, vec3(0, 1, 0), 1.0);
    float planeID = 2.0;
    vec2 plane = vec2(planeDist, planeID);
    // sphere
    float sphereDist = fSphere(p, 1.0);
    float sphereID = 1.0;
    vec2 sphere = vec2(sphereDist, sphereID);
    // result
    vec2 res = fOpUnion(plane, sphere);
    return res;
}

vec2 rayMarch(vec3 ro, vec3 rd) {
    vec2 hit, object;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + object.x * rd;
        hit = map(p);
        object.x += hit.x;
        object.y = hit.y;
        if (abs(hit.x) < EPSILON || object.x > MAX_DIST) break;
    }
    return object;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(EPSILON, 0.0);
    vec3 n = vec3(map(p).x) - vec3(map(p - e.xyy).x, map(p - e.yxy).x, map(p - e.yyx).x);
    return normalize(n);
}

vec3 getLight(vec3 p, vec3 rd, vec3 color) {
    vec3 lightPos = vec3(20.0, 40.0, -30.0);
    vec3 L = normalize(lightPos - p);
    vec3 N = getNormal(p);
    // Lamberts law
    vec3 diffuse = color * clamp(dot(L, N), 0.0, 1.0);
    return diffuse;
}

vec3 getMaterial(vec3 p, float id) {
    vec3 m;
    switch (int(id)) {
        case 1:
        m = vec3(0.9, 0.9, 0.0);
        break;
        case 2:
        m = vec3(0.0, 0.5, 0.5);
        break;
    }
    return m;
}

void render(inout vec3 col, in vec2 uv) {
    vec3 ro = vec3(0.0, 0.0, -3.0);
    vec3 rd = normalize(vec3(uv, FOV));

    vec2 object = rayMarch(ro, rd);

    if (object.x < MAX_DIST) {
        vec3 p = ro + object.x * rd;
        vec3 material = getMaterial(p, object.y);
        col += getLight(p, rd, material);
    }
}

void main() {
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;

    vec3 col;
    render(col, uv);

    fragColor = vec4(col, 1.0);
}