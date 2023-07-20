%#codegen
function out=sldvcoder_lookupND1D_lin_clip(u,...
    x,nx,table,...
    variant,output_ex,roundingMode)














    coder.allowpcode('plain');

    coder.internal.prefer_const(variant);





    if isfloat(u)||isfloat(x)||isfloat(table)||isfloat(output_ex)
        if variant==0
            out=sldvcoder_lookupND_stub_bounded(u,table,nx,output_ex);
        else
            out=sldvcoder_lookupND1D_precomp(u,x,nx,table,output_ex,1);
        end
    else
        out=sldvcoder_fxp_lookupND1D_lin_clip_approx(u,x,nx,table,roundingMode,output_ex);
    end
end
