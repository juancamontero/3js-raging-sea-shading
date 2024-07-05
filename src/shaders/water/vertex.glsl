uniform float uTime;
uniform float uBigWavesElevation;
uniform vec2 uBigWavesFrequency;
uniform float uBigWavesSpeed;

uniform float uSmallWavesElevation;
uniform float uSmallWavesFrequency;
uniform float uSmallWavesSpeed;
uniform float uSmallIterations;
uniform float uNormalShift;

varying float vElevation;
varying vec3 vNormal; //? to be used in the lights
varying vec3 vPosition; //? to get viewDirection

#include ../includes/perlinClassic3D.glsl

float waveElevation(vec3 position)
{
    float elevation = sin(position.x * uBigWavesFrequency.x + uTime * uBigWavesSpeed) *
                      sin(position.z * uBigWavesFrequency.y + uTime * uBigWavesSpeed) *
                      uBigWavesElevation;

    for(float i = 1.0; i <= uSmallIterations; i++)
    {
        elevation -= abs(perlinClassic3D(vec3(position.xz * uSmallWavesFrequency * i, uTime * uSmallWavesSpeed)) * uSmallWavesElevation / i);
    }
    
    return elevation;
}


void main()
{
    // Base position
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);

    // * NORMAL CALCULATION
    // Se debe actualizar la normal con el model position, 
    // se va  a usar the neighbours technique: supone 2 vecinos a una distancia "SHIFT" - parámetro
    // los vecinos se ubican: vecinoA +SHIFT en X ,  vecinoB -SHIFT en Z (ley mano deracha para el cross product)
    // se precisa tener una función para calcular la elevación

    //?With a smaller shift, we might catch elevation details that won’t be visible in the final waves.
    //? With a bigger shift, we might miss elevation details
    // float shift = 0.01;
    float shift = uNormalShift;

    //? neighbours
    vec3 modelPositionA = modelPosition.xyz + vec3(shift,0.0,0.0);
    vec3 modelPositionB = modelPosition.xyz + vec3(0.0,0.0,-shift);

    // Elevation
    float elevation = waveElevation(modelPosition.xyz);
    modelPosition.y += elevation;

    //? to apply elevation to the neighbours
    modelPositionA.y += waveElevation(modelPositionA);
    modelPositionB.y += waveElevation(modelPositionB);

    //? get the neighbours direction
    vec3 toA = normalize(modelPositionA - modelPosition.xyz);
    vec3 toB = normalize(modelPositionB - modelPosition.xyz);

    //? the cross product betwaan toA & toB is the normal
    //? es la normal de plano creado por los 2 vectores
    vec3 computedNormal = cross(toA, toB); //? el orden importa



    // Finale positopm
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    // Varyings
    vElevation = elevation;
    vPosition = modelPosition.xyz;
    // vNormal = (modelMatrix * vec4(normal, 0.0)).xyz; //? 0 cause no translation is applied
    //! this normal allways be 1 'cause is the plane normals, the 'normal' uniform is the plane normal
    //todo : remove the normal attribute to performance "waterGeometry.deleteAttribute('normal')"

    vNormal = computedNormal;

 

}