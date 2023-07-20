%#codegen
function out=sldvcoder_lookupND2D_lin_clip(ux,uy,...
    x,nx,y,ny,table,...
    variant,output_ex,roundingMode)














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,y,ny,table,variant,output_ex);

    if isfloat(ux)||isfloat(uy)||isfloat(x)||isfloat(y)||...
        isfloat(table)||isfloat(output_ex)
        if variant==0



            out=sldvcoder_lookupND_stub_bounded(ux,table,nx*ny,output_ex);
        else
            out=sldvcoder_lookupND2D_lin_clip_approx(ux,uy,x,nx,y,ny,table,output_ex);
        end
    else
        out=sldvcoder_fxp_lookupND2D_lin_clip_approx(ux,uy,x,nx,y,ny,table,roundingMode,output_ex);
    end
end
