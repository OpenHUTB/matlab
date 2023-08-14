function initNonTagInstrBlock(block)




    if slplc.utils.isRunningModelGeneration(block)
        return
    end


    if plcfeature('PLCLadderBlockHierarchyCheck')
        slplc.utils.blockHeirarchyCheck(block);
    end
end
