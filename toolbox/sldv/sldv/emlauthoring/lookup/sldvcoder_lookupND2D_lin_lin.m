%#codegen
function out=sldvcoder_lookupND2D_lin_lin(ux,uy,...
    x,nx,y,ny,table,...
    variant,output_ex,~)














    coder.allowpcode('plain');

    eml_prefer_const(x,nx,y,ny,table,variant,output_ex);

    if variant==0




        out=sldv.stub(ux);
    else
        out=sldvcoder_lookupND2D_lin_lin_approx(ux,uy,x,nx,y,ny,table,output_ex);
    end
end