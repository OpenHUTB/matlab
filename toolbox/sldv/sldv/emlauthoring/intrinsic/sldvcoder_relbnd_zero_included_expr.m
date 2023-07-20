%#codegen
function out=sldvcoder_relbnd_zero_included_expr(inLarge,inSmall)






    coder.allowpcode('plain');
    if inLarge>=inSmall
        tol=sldvcoder_relbnd_tolerance(inLarge,inSmall);
        out=(inLarge-tol)<inSmall;
    else
        out=false;
    end

end