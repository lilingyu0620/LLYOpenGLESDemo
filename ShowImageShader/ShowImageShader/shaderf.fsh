
precision mediump float;

varying lowp vec2 varyTextCoord;

uniform sampler2D colorMap;


void main()
{
    vec4 mask = texture2D(colorMap, varyTextCoord);
    gl_FragColor = vec4(mask.rgb,1.0);
}
