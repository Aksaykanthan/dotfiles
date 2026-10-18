// Starfield: a slow, dim, parallax drift of Catppuccin-tinted stars behind
// the terminal, in the spirit of DevOps Toolbox's Ghostty background.
// Stars only paint where the cell is (close to) the background colour, so
// text and the cursor stay untouched. Written for this repo (MIT, like it).
//
// Tunables:
#define LAYERS      3       // depth layers (parallax)
#define DENSITY     18.0    // grid cells across the shorter screen side
#define SPEED       0.015   // drift speed
#define BRIGHTNESS  0.55    // max star intensity
#define BG_THRESH   0.12    // how close to background a pixel must be

const vec3 TINT[3] = vec3[3](
    vec3(0.80, 0.84, 0.96),  // text     #cdd6f4
    vec3(0.80, 0.65, 0.97),  // mauve    #cba6f7
    vec3(0.54, 0.71, 0.98)   // blue     #89b4fa
);

float hash(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

vec3 starLayer(vec2 uv, float layer, float t) {
    float depth = 1.0 + layer * 0.8;
    vec2 p = uv * DENSITY * depth + vec2(t * SPEED * 60.0 / depth, t * SPEED * 20.0 / depth) + layer * 13.7;
    vec2 cell = floor(p);
    vec2 f = fract(p) - 0.5;

    float h = hash(cell + layer * 7.1);
    if (h < 0.75) return vec3(0.0);                 // most cells are empty

    vec2 offset = vec2(hash(cell + 1.3), hash(cell + 2.9)) - 0.5;
    float d = length(f - offset * 0.7);
    float size = 0.02 + 0.05 * hash(cell + 4.7) / depth;
    float twinkle = 0.6 + 0.4 * sin(t * (0.5 + h * 1.5) + h * 40.0);
    float star = smoothstep(size, 0.0, d) * twinkle / depth;

    return TINT[int(mod(h * 97.0, 3.0))] * star;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    vec2 suv = fragCoord / min(iResolution.x, iResolution.y);
    vec3 stars = vec3(0.0);
    for (int i = 0; i < LAYERS; i++) {
        stars += starLayer(suv, float(i), iTime);
    }

    // Fade stars out wherever the pixel isn't plain background.
    float isBg = 1.0 - smoothstep(0.0, BG_THRESH, distance(term.rgb, iBackgroundColor));
    fragColor = vec4(term.rgb + stars * BRIGHTNESS * isBg, term.a);
}
