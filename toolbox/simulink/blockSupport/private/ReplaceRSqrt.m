function ReplaceRSqrt(blk,h)





    if askToReplace(h,blk)

        outDt=get_param(blk,'OutDataTypeStr');
        sampleT=get_param(blk,'SampleTime');
        algType=get_param(blk,'AlgorithmType');
        nIterat=get_param(blk,'Iterations');
        intermDT=get_param(blk,'IntermediateResultsDataTypeStr');

        funcSet=uReplaceBlock(h,blk,'built-in/Sqrt',...
        'Operator','rSqrt',...
        'OutDataTypeStr',outDt,...
        'SampleTime',sampleT,...
        'AlgorithmType',algType,...
        'Iterations',nIterat,...
        'IntermediateResultsDataTypeStr',intermDT);
        appendTransaction(h,blk,h.ReplaceBlockReasonStr,{funcSet});
    end

end
