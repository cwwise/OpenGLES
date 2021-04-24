attribute vec2 position;
varying vec2 vTexcoord;

void main (void) {
    gl_Position = vec4(position, 0.0, 1.0);
    vTexcoord = position * 0.5 + 0.5;
}
