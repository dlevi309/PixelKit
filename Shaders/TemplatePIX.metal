//
//  TemplatePIX.metal
//  PixelKit Shaders
//
//  Created by Hexagons on 2017-11-17.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float distToLine(float2 p1, float2 p2, float2 point) {
    float a = p1.y-p2.y;
    float b = p2.x-p1.x;
    return abs(a*point.x+b*point.y+p1.x*p2.y-p2.x*p1.y) / sqrt(a*a+b*b);
}

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float resx;
    float resy;
    float aspect;
};

fragment float4 templatePIX(VertexOut out [[stage_in]],
                            const device Uniforms& in [[ buffer(0) ]],
                            sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    v = 1 - v; // Content Flip Fix
    float2 uv = float2(u, v);
    
    float c = 0;
    float d = 32;
    float ry = 1.0 / in.resy;
    float r = ry * d;
    
    if (u < r || u > 1.0 - r) {
        c = 1.0;
    }
    if (v < r || v > 1.0 - r) {
        c = 1.0;
    }
    
    float dist = sqrt(pow((u - 0.5) * in.aspect, 2) + pow(v - 0.5, 2));
    if (dist > 0.5 - r && dist < 0.5) {
        c = 1.0;
    }
    if (dist > in.aspect / 2 - r && dist < in.aspect / 2) {
        c = 1.0;
    }
    
    float line1 = distToLine(float2(0.0, 0.0), float2(1.0, 1.0), uv);
    if (line1 < r / 2) {
        c = 1.0;
    }
    float line2 = distToLine(float2(0.0, 1.0), float2(1.0, 0.0), uv);
    if (line2 < r / 2) {
        c = 1.0;
    }
    
    return float4(u * c, v * c, c, c);
}