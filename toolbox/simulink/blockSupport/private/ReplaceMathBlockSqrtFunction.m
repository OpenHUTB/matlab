function ReplaceMathBlockSqrtFunction(blk,h,Data)


    if askToReplace(h,blk)
        if Data==1,

            newFcn='signedSqrt';
            reason=DAStudio.message('SimulinkBlocks:upgrade:mathBlockSqrtFunction1');

        else

            newFcn='sqrt';
            reason=DAStudio.message('SimulinkBlocks:upgrade:mathBlockSqrtFunction2');

        end

        outDt=get_param(blk,'OutDataTypeStr');
        outSt=get_param(blk,'OutputSignalType');
        sampleT=get_param(blk,'SampleTime');
        algType=get_param(blk,'AlgorithmType');
        nIterat=get_param(blk,'Iterations');
        intermDT=get_param(blk,'IntermediateResultsDataTypeStr');

        funcSet=uReplaceBlock(h,blk,'built-in/Sqrt',...
        'Operator',newFcn,...
        'OutDataTypeStr',outDt,...
        'OutputSignalType',outSt,...
        'SampleTime',sampleT,...
        'AlgorithmType',algType,...
        'Iterations',nIterat,...
        'IntermediateResultsDataTypeStr',intermDT);

        appendTransaction(h,blk,reason,{funcSet});
    end

end
