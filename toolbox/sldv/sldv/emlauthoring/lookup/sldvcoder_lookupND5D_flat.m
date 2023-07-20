%#codegen
function out=sldvcoder_lookupND5D_flat(ux,uy,uz,uv,uw,...
    x,nx,y,ny,z,nz,v,nv,w,nw,table,...
    variant,output_ex)%#ok<INUSL>














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,y,ny,z,nz,v,nv,w,nw,table,variant,output_ex);




    out=sldvcoder_lookupND_stub_bounded(ux,table,nx*ny*nz*nv*nw,output_ex);
end