%#codegen
function out=sldvcoder_relbnd_test(inLarge,inSmall,relOp,exprId)












































    coder.allowpcode('plain');

    if isa(inLarge,'double')||isa(inSmall,'double')
        inLarge=double(inLarge);
        inSmall=double(inSmall);
    else
        inLarge=single(inLarge);
        inSmall=single(inSmall);
    end

    coder.extrinsic('sldvprivate');
    res=coder.const(sldvprivate('isRelationalBoundaryOn'));


    if~res
        out=false;
        return;
    end

    if(exprId==0)
        if((relOp==3)||(relOp==4))
            out=sldvcoder_relbnd_zero_included_expr(inLarge,inSmall);
        else
            out=sldvcoder_relbnd_zero_excluded_expr(inLarge,inSmall);
        end
    elseif(exprId==1)
        if((relOp==2)||(relOp==5))
            out=sldvcoder_relbnd_zero_included_expr(inLarge,inSmall);
        else
            out=sldvcoder_relbnd_zero_excluded_expr(inLarge,inSmall);
        end
    else
        assert(false,'Bad expression ID. Should be 0 or 1');
        out=false;
    end

end


