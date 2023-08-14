function initProgram(pouBlock,varargin)




    if slplc.utils.isRunningModelGeneration(pouBlock)
        return
    end


    slplc.utils.modelSanityChecker(pouBlock);

    pouType=slplc.utils.getParam(pouBlock,'PLCPOUType');
    if~strcmpi(pouType,'program')
        error('slplc:invalidProgramPOU',...
        '%s is not a PLC Program POU block',pouBlock);
    end


    pouBlkType=slplc.utils.getParam(pouBlock,'PLCBlockType');
    if plcfeature('PLCLadderBlockHierarchyCheck')&&ismember(pouBlkType,{'LDProgram'})
        slplc.utils.blockHeirarchyCheck(pouBlock);
    end

    slplc.utils.updateVariableList(pouBlock);
    slplc.utils.generateFBData(pouBlock);

    slplc.utils.updateDataBlocks(pouBlock);
    slplc.utils.refreshPOUVarSS(pouBlock);

    skipRoutineInit=false;
    if~isempty(varargin)
        skipRoutineInit=varargin{1};
    end

    if~skipRoutineInit
        slplc.utils.initRoutines(pouBlock);
    end


    if isempty(slplc.utils.getParentPOU(pouBlock))
        slplc.utils.setClockSampleTime(pouBlock);
    end

    slplc.utils.validateInitialValue(pouBlock);
end


