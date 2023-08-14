function initInstruction(block,varargin)




    if slplc.utils.isRunningModelGeneration(block)
        return
    end


    slplc.utils.modelSanityChecker(block);

    if bdIsLibrary(bdroot(block))
        return
    end

    if plcfeature('PLCLadderBlockHierarchyCheck')
        slplc.utils.blockHeirarchyCheck(block);
    end


    slplc.utils.setDSMExpression(block,varargin{:});
end


