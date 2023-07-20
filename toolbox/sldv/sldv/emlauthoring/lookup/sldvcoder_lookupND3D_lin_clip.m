%#codegen
function out=sldvcoder_lookupND3D_lin_clip(ux,uy,uz,...
    x,nx,y,ny,z,nz,table,...
    variant,output_ex)%#ok<INUSL>














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,y,ny,z,nz,table,variant,output_ex);




    out=sldvcoder_lookupND_stub_bounded(ux,table,nx*ny*nz,output_ex);
end