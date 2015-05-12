#version 330 compatibility

#pragma vp_name       "REX Engine - Vertex"
#pragma vp_entryPoint "oe_rexEngine_vert"
#pragma vp_location   "vertex_model"
#pragma vp_order      "0.5"

#define REX_LOD_BLENDING

// outputs
out vec4 oe_layer_texc;
out vec4 oe_layer_tilec;
out vec4 oe_layer_texcparent;
out float oe_rexlod_r;

out vec3 vp_Normal;

uniform mat4      oe_layer_texMatrix;
uniform mat4      oe_layer_parentTexMatrix;
uniform sampler2D oe_tile_elevationTex;
uniform mat4      oe_tile_elevationTexMatrix;
uniform sampler2D oe_tile_parentElevationTex;
uniform mat4      oe_tile_parentElevationTexMatrix;

uniform vec4      oe_tile_key;
uniform float     oe_min_tile_range_factor;
uniform float     oe_tile_birthtime;
uniform float     osg_FrameTime;
uniform float     oe_lodblend_delay;
uniform float     oe_lodblend_duration;

void oe_rexEngine_vert(inout vec4 vertexModel)
{
    // Texture coordinate for the tile (always 0..1)
    oe_layer_tilec = gl_MultiTexCoord0;

    // Texture coordinate for the color texture (scale,bias)
    oe_layer_texc = oe_layer_texMatrix * oe_layer_tilec;

#if 0
    // Sample the elevation texture and move the vertex accordingly.
    vec4 elevc = oe_tile_elevationTexMatrix * oe_layer_tilec;
    float elev = texture2D(oe_tile_elevationTex, elevc.st).r;
    vertexModel.xyz = vertexModel.xyz + vp_Normal*elev;
    
#ifdef REX_LOD_BLENDING
    oe_layer_texcparent = oe_layer_parentTexMatrix * oe_layer_tilec;
    
    vec4 pElevc = oe_tile_parentElevationTexMatrix * oe_layer_tilec;
    float pElev = texture2D(oe_tile_parentElevationTex, pElevc.st).r;
    
    float radius     = oe_tile_key.w;
    float near       = oe_min_tile_range_factor*radius;
    float far        = near + radius*2.0;
    vec4  VertexVIEW = gl_ModelViewMatrix * vertexModel;
    float d          = length(VertexVIEW.xyz/VertexVIEW.w);
    float r_dist     = clamp((d-near)/(far-near), 0.0, 1.0);
    
    float r_time     = 1.0 - clamp(osg_FrameTime-(oe_tile_birthtime+oe_lodblend_delay), 0.0, oe_lodblend_duration)/oe_lodblend_duration;
    float r          = max(r_dist, r_time);
    
    vec3 lodOffset = vp_Normal * r * (pElev-elev);
    vertexModel += vec4(lodOffset*vertexModel.w, 0.0);
    
    oe_rexlod_r = oe_layer_parentTexMatrix[0][0] > 0.0 ? r : 0.0;
#endif
#endif
}
