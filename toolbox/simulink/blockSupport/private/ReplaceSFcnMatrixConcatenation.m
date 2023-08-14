function ReplaceSFcnMatrixConcatenation(block,h)










    if askToReplace(h,block)
        funcSet=uSafeSetParam(...
        h,block,'SourceBlock',...
        sprintf('simulink/Math\nOperations/Matrix\nConcatenate'));
        appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
    end

end
