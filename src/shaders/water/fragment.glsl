uniform vec3 uDepthColor;
uniform vec3 uSurfaceColor;
uniform float uColorOffset;
uniform float uColorMultiplier;

varying float vElevation;
varying vec3 vNormal;
varying vec3 vPosition; //? to get viewDirection

#include ../includes/directionalLight.glsl //todo: get viewDirection
#include ../includes/pointLight.glsl

void main()
{
    //  Base color
    float mixStrength = (vElevation + uColorOffset) * uColorMultiplier;

    //? To make the color change morw abrupt, pasa de 0 a 1 unsando el smooth
    mixStrength = smoothstep(0.0, 1.0, mixStrength);
    vec3 color = mix(uDepthColor, uSurfaceColor, mixStrength);

    // Light

    //* Get viewDirection & normals
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);
    
    //? starts with a "black" light , las demás luces se suman en esta variable
    vec3 light = vec3(0.0); 

    //* Directional Light
    // light+= directionalLight(
    //     vec3(1.0),            // Light color
    //     1.0,                  // Light intensity,
    //     normal,               // Normal
    //     vec3(-1.0, 0.5, 0.0), // Light position
    //     viewDirection,        // View direction
    //     30.0                  // Specular power
    // );

    light += pointLight(
        vec3(1.0),            // Light color
        10.0,                 // Light intensity,
        normal,               // Normal
        vec3(0.0, 0.25, 0.0), // Light position
        viewDirection,        // View direction
        30.0,                 // Specular power
        vPosition,            // Position
        0.95                  // Decay
    );

    color *= light;
    
    //  Final color
    // gl_FragColor = vec4(color, 1.0);
    gl_FragColor = vec4(color, 1.0); //? to test normal value
    
    //? cause we are going to add in the material script tone mapping
    #include <tonemapping_fragment> 
    #include <colorspace_fragment>
}