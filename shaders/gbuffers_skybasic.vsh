#version 400 compatibility

uniform vec3 cameraPosition;


void main() {
    gl_Position = ftransform();
}