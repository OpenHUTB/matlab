function initController(controllerBlock)




    if slplc.utils.isRunningModelGeneration(controllerBlock)
        return
    end


    slplc.utils.modelSanityChecker(controllerBlock);

    pouType=slplc.utils.getParam(controllerBlock,'PLCPOUType');
    if~strcmpi(pouType,'PLC Controller')
        error('slplc:invalidSystemBlock',...
        '%s is not a PLC Controller block',controllerBlock);
    end


    if plcfeature('PLCLadderBlockHierarchyCheck')
        slplc.utils.blockHeirarchyCheck(controllerBlock);
    end

    slplc.utils.updateVariableList(controllerBlock);
    slplc.utils.generateFBData(controllerBlock);

    slplc.utils.updateDataBlocks(controllerBlock);
    slplc.utils.refreshControllerVarSS(controllerBlock);
    slplc.utils.initRoutines(controllerBlock);

    slplc.utils.setClockSampleTime(controllerBlock);
    slplc.utils.validateInitialValue(controllerBlock);
end


