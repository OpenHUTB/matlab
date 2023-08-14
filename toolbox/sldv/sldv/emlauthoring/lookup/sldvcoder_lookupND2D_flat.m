%#codegen
function out=sldvcoder_lookupND2D_flat(ux,uy,...
    x,nx,y,ny,table,...
    variant,output_ex,~)%#ok<INUSL>














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,y,ny,table,variant,output_ex);




    out=sldvcoder_lookupND_stub_bounded(ux,table,nx*ny,output_ex);
end