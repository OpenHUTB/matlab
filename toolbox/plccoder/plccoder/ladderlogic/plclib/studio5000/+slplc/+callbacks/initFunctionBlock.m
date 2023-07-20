function initFunctionBlock(pouBlock)




    if slplc.utils.isRunningModelGeneration(pouBlock)
        return
    end


    slplc.utils.modelSanityChecker(pouBlock);

    if plcfeature('PLCLadderBlockHierarchyCheck')
        slplc.utils.blockHeirarchyCheck(pouBlock);
    end

    pouType=slplc.utils.getParam(pouBlock,'PLCPOUType');
    if~strcmpi(pouType,'Function block')
        error('slplc:invalidFBPOU',...
        '%s is not a PLC Function Block POU block',pouBlock);
    end

    slplc.utils.updateVariableList(pouBlock);
    slplc.utils.setDSMExpression(pouBlock);

    slplc.utils.updateDataBlocks(pouBlock);
    slplc.utils.refreshPOUVarSS(pouBlock);
    slplc.utils.initRoutines(pouBlock);

    slplc.utils.validateInitialValue(pouBlock);
end


