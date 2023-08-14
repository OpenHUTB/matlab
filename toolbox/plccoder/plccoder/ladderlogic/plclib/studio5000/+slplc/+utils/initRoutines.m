function initRoutines(organizationBlock)

    if contains(bdroot(organizationBlock),'studio5000_plclib')
        return
    end

    routineBlocks=slplc.utils.getRoutineBlocks(organizationBlock);
    orgnizationBlockLabelLists=cell(numel(routineBlocks),1);
    for routineCount=1:numel(routineBlocks)
        routineBlk=routineBlocks{routineCount};
        orgnizationBlockLabelLists{routineCount}=slplc.utils.updateLabelDataBlocks(routineBlk);
        slplc.utils.initSemantics(routineBlk);
    end
    removeOutOfScopeLabelBlocks(organizationBlock,orgnizationBlockLabelLists);
end

function removeOutOfScopeLabelBlocks(organizationBlock,orgnizationBlockLabelLists)
    pouType=slplc.utils.getParam(organizationBlock,'PLCPOUType');
    if~isempty(pouType)&&strcmpi(pouType,'Function Block')
        organizationBlock=slplc.utils.getInternalBlockPath(organizationBlock,'Enable');
    end
    labelDataBlocks=plc_find_system(organizationBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name','^_\w+_Label$',...
    'BlockType','DataStoreMemory');
    for listCount=1:numel(orgnizationBlockLabelLists)
        currentList=orgnizationBlockLabelLists{listCount};
        scopedDataBlocks=getScopeDataBlocks(organizationBlock,currentList,'Label');
        labelDataBlocks=setdiff(labelDataBlocks,scopedDataBlocks);
    end
    for blockCount=1:numel(labelDataBlocks)
        dataBlk=labelDataBlocks{blockCount};
        if getSimulinkBlockHandle(dataBlk)>0
            delete_block(dataBlk);
        end
    end

    labelInitValueBlocks=plc_find_system(organizationBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name','^_\w+_LabelInitValue$',...
    'BlockType','Constant');
    for listCount=1:numel(orgnizationBlockLabelLists)
        currentList=orgnizationBlockLabelLists{listCount};
        scopedDataBlocks=getScopeDataBlocks(organizationBlock,currentList,'LabelInitValue');
        labelInitValueBlocks=setdiff(labelInitValueBlocks,scopedDataBlocks);
    end

    for blockCount=1:numel(labelInitValueBlocks)
        dataBlk=labelInitValueBlocks{blockCount};
        removeDataResetBlocks(dataBlk);
    end

    labelAssertBlocks=plc_find_system(organizationBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name','^_\w+_LabelAssert$',...
    'BlockType','DataStoreRead');
    for listCount=1:numel(orgnizationBlockLabelLists)
        currentList=orgnizationBlockLabelLists{listCount};
        scopedDataBlocks=getScopeDataBlocks(organizationBlock,currentList,'LabelAssert');
        labelAssertBlocks=setdiff(labelAssertBlocks,scopedDataBlocks);
    end

    for blockCount=1:numel(labelAssertBlocks)
        assertBlk=labelAssertBlocks{blockCount};
        removeAssertBlocks(assertBlk);
    end

end

function scopedDataBlocks=getScopeDataBlocks(organizationBlock,labelList,tailStr)
    scopedDataBlocks=cell(numel(labelList),1);
    for blkCount=1:numel(labelList)
        scopedDataBlocks{blkCount}=[organizationBlock,'/',labelList(blkCount).DataName,'_',tailStr];
    end
end

function removeDataResetBlocks(labelInitValueBlock)
    dataParentBlk=get_param(labelInitValueBlock,'parent');
    dataName=strrep(get_param(labelInitValueBlock,'Name'),'_LabelInitValue','');
    if getSimulinkBlockHandle(labelInitValueBlock)>0
        constantBlkH=get_param(labelInitValueBlock,'LineHandles');
        delete_line(constantBlkH.Outport(1));
        delete_block(labelInitValueBlock);
    end
    dataResetBlkFullName=[dataParentBlk,'/',dataName,'_LabelReset'];
    if getSimulinkBlockHandle(dataResetBlkFullName)>0
        delete_block(dataResetBlkFullName);
    end
end

function removeAssertBlocks(labelAssertBlock)
    dataParentBlk=get_param(labelAssertBlock,'parent');
    dataName=strrep(get_param(labelAssertBlock,'Name'),'_LabelAssert','');
    if getSimulinkBlockHandle(labelAssertBlock)>0
        dsrBlkH=get_param(labelAssertBlock,'LineHandles');
        delete_line(dsrBlkH.Outport(1));
        delete_block(labelAssertBlock);
    end
    assertionBlkFullName=[dataParentBlk,'/',dataName,'_AssertZero'];
    if getSimulinkBlockHandle(assertionBlkFullName)>0
        delete_block(assertionBlkFullName);
    end
end