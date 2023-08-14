function ReplaceSFcnReshape(block,h)








    if askToReplace(h,block)
        funcSet=uSafeSetParam(...
        h,block,'SourceBlock',...
        sprintf('simulink/Math\nOperations/Reshape'));
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
