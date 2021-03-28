attribute vec3 position;
attribute vec3 color;

varying vec3 outColor;

uniform float pointSize;

void main()
{
    gl_Position = vec4(position, 1.0);
//    gl_PointSize = pointSize;
    outColor = color;
}
