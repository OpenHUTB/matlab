function ReplaceDotProduct(block,h)








    if askToReplace(h,block)
        pFuncSet=uSafeSetParam(h,block,'linkStatus','none');
        rFuncSet=uReplaceBlockWithLink(h,block);
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{pFuncSet,rFuncSet});
    end

end
