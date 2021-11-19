#version 400 compatibility

in vec2 texcoord;
in vec4 glColor;

layout(location = 0) out vec4 shadowColor;

uniform sampler2D texture;
uniform float alphaTestRef;

void main() {
    shadowColor = texture2D(texture, texcoord) * glColor;
    if (shadowColor.a < alphaTestRef) discard;
}