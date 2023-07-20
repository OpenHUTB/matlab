%#codegen
function out=sldvcoder_lookupND3D_lin_lin(ux,uy,uz,...
    x,nx,y,ny,z,nz,table,...
    variant,output_ex)%#ok<INUSL>














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,y,ny,z,nz,table,variant,output_ex);





    out=sldv.stub(ux);
end