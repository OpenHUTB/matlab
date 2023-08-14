function utilCleanTargetInterfaceTable(mdladvObj,hDI)




    if hDI.isIPCoreGen||hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow||...
        hDI.showReferenceDesignTasks
        hDI.hTurnkey.hTable.cleanInterfaceTable;
        hDI.hTurnkey.hTable.cleanPIR;
        utilUpdateInterfaceTable(mdladvObj,hDI);
    end

end


