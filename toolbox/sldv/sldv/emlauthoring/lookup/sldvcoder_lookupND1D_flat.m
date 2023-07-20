%#codegen
function out=sldvcoder_lookupND1D_flat(u,...
    x,nx,table,...
    variant,output_ex,~)














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,table,variant);


    out=sldvcoder_lookupND1D_lin_clip(u,x,nx,table,0,output_ex);
end