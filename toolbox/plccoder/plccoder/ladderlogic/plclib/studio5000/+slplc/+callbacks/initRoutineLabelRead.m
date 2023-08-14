function initRoutineLabelRead(labelCoreReadBlock)




    if slplc.utils.isRunningModelGeneration(labelCoreReadBlock)
        return
    end

    parentBlock=get_param(labelCoreReadBlock,'Parent');
    if strcmp(parentBlock,bdroot(labelCoreReadBlock))

        return
    end

    plcBlockType=slplc.utils.getParam(parentBlock,'PLCBlockType');
    if~isempty(plcBlockType)&&...
        ismember(plcBlockType,{'BlockEnableRead','ForceRungInFalseRead','VariableWriteEnableRead'})
        ownerBlk=parentBlock;
        pouBlk=slplc.utils.getParentPOU(ownerBlk);
        routineBlk=get_param(pouBlk,'Parent');
        plcBlkType=slplc.utils.getParam(routineBlk,'PLCBlockType');
        if~isempty(plcBlkType)&&strcmpi(plcBlkType,'Task')
            routineBlk=get_param(routineBlk,'Parent');
        end
    else
        ownerBlk=slplc.utils.getParentPOU(labelCoreReadBlock,'Scoped');
        routineBlk=get_param(ownerBlk,'Parent');
    end

    labelTag=get_param(ownerBlk,'PLCLabelTag');
    [~,dsmDataName]=slplc.utils.parseRoutineLabel(routineBlk,labelTag);


    dataReadBlock=[labelCoreReadBlock,'/DataRead'];
    set_param(dataReadBlock,'DataStoreElements','');
    set_param(dataReadBlock,'DataStoreName',dsmDataName);
    set_param(dataReadBlock,'DataStoreElements','');
end