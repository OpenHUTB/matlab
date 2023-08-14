%#codegen
function out=sldvcoder_lookupND5D_lin_lin(ux,uy,uz,uv,uw,...
    x,nx,y,ny,z,nz,v,nv,w,nw,table,...
    variant,output_ex)%#ok<INUSL>














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,y,ny,z,nz,v,nv,w,nw,table,variant,output_ex);





    out=sldv.stub(ux);
end