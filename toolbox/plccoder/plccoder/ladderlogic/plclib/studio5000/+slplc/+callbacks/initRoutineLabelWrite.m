function initRoutineLabelWrite(labelCoreWriteBlock)




    if slplc.utils.isRunningModelGeneration(labelCoreWriteBlock)
        return
    end

    parentBlock=get_param(labelCoreWriteBlock,'Parent');
    if strcmp(parentBlock,bdroot(labelCoreWriteBlock))

        return
    end

    plcBlockType=slplc.utils.getParam(parentBlock,'PLCBlockType');
    if~isempty(plcBlockType)&&...
        ismember(plcBlockType,{'BlockEnableWrite','ForceRungInFalseWrite','VariableWriteEnableWrite'})
        ownerBlk=parentBlock;
        pouBlk=slplc.utils.getParentPOU(ownerBlk);
        routineBlk=get_param(pouBlk,'Parent');
    else
        ownerBlk=slplc.utils.getParentPOU(labelCoreWriteBlock,'Scoped');
        routineBlk=get_param(ownerBlk,'Parent');
    end

    labelTag=get_param(ownerBlk,'PLCLabelTag');
    [~,dsmDataName]=slplc.utils.parseRoutineLabel(routineBlk,labelTag);


    dataWriteBlock=[labelCoreWriteBlock,'/DataWrite'];
    set_param(dataWriteBlock,'DataStoreElements','');
    set_param(dataWriteBlock,'DataStoreName',dsmDataName);
    set_param(dataWriteBlock,'DataStoreElements','');
end