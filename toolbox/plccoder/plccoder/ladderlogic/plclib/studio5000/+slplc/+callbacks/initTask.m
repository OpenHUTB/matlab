function initTask(taskBlock)




    if slplc.utils.isRunningModelGeneration(taskBlock)
        return
    end


    slplc.utils.modelSanityChecker(taskBlock);


    if plcfeature('PLCLadderBlockHierarchyCheck')
        slplc.utils.blockHeirarchyCheck(taskBlock);
    end
end
