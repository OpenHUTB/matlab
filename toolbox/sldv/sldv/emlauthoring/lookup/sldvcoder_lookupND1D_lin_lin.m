%#codegen
function out=sldvcoder_lookupND1D_lin_lin(u,...
    x,nx,table,...
    variant,output_ex,~)














    coder.allowpcode('plain');

    coder.internal.prefer_const(variant);





    if variant==0
        out=sldv.stub(u);
    else
        out=sldvcoder_lookupND1D_precomp(u,x,nx,table,output_ex,0);
    end
end
