function ReplaceHDLReciprocal(blk,h)



    if askToReplace(h,blk)

        nIterat=get_param(blk,'NumberOfIterations');
        funcSet=uReplaceBlock(h,blk,'built-in/Math',...
        'Operator','Reciprocal',...
        'AlgorithmMethod','Newton-Raphson',...
        'Iterations',nIterat);
        appendTransaction(h,blk,h.ReplaceBlockReasonStr,{funcSet});
    end
end
