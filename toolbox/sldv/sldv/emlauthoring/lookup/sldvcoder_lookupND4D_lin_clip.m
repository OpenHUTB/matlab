%#codegen
function out=sldvcoder_lookupND4D_lin_clip(ux,uy,uz,uv,...
    x,nx,y,ny,z,nz,v,nv,table,...
    variant,output_ex)%#ok<INUSL>














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,y,ny,z,nz,v,nv,table,variant,output_ex);




    out=sldvcoder_lookupND_stub_bounded(ux,table,nx*ny*nz*nv,output_ex);
end