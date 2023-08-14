function routineLabelList=updateLabelDataBlocks(routineBlock)

    routineLabelList=slplc.utils.getRoutineLabel(routineBlock);
    existentLabelDataNames=getExistentLabelDataNames(routineBlock);
    if isempty(routineLabelList)
        toDeleteDataNames=existentLabelDataNames;
    else
        toDeleteDataNames=setdiff(existentLabelDataNames,{routineLabelList.DataName});
    end

    dataParentBlock=get_param(routineBlock,'parent');
    for dataCount=1:numel(toDeleteDataNames)
        dataName=toDeleteDataNames{dataCount};
        removeDataBlock(dataParentBlock,dataName);
        removeDataResetBlocks(dataParentBlock,dataName);
    end

    for dataCount=1:numel(routineLabelList)
        locUpdateLabelBlks(routineBlock,routineLabelList(dataCount));
    end

    formatDataBlocks(routineBlock);
end

function removeDataBlock(dataParentBlock,dataName)
    dataBlk=[dataParentBlock,'/',dataName,'_Label'];
    if getSimulinkBlockHandle(dataBlk)>0
        delete_block(dataBlk);
    end
end

function removeDataResetBlocks(dataParentBlock,dataName)
    constantFullName=[dataParentBlock,'/',dataName,'_LabelInitValue'];
    if getSimulinkBlockHandle(constantFullName)>0
        constantBlkH=get_param(constantFullName,'LineHandles');
        delete_line(constantBlkH.Outport(1));
        delete_block(constantFullName);
    end
    dataResetBlkFullName=[dataParentBlock,'/',dataName,'_LabelReset'];
    delete_block(dataResetBlkFullName);
end

function locUpdateLabelBlks(routineBlock,labelInfo)
    dataParentBlk=get_param(routineBlock,'parent');
    dataBlkFullName=[dataParentBlk,'/',labelInfo.DataName,'_Label'];
    if getSimulinkBlockHandle(dataBlkFullName)<=0

        msgSetting='none';
        priority='10';
        safe_add_block('simulink/Signal Routing/Data Store Memory',dataBlkFullName);
        set_param(dataBlkFullName,'WriteAfterReadMsg',msgSetting);
        set_param(dataBlkFullName,'ReadBeforeWriteMsg',msgSetting);
        set_param(dataBlkFullName,'WriteAfterWriteMsg',msgSetting);
        set_param(dataBlkFullName,'Priority',priority);
        set_param(dataBlkFullName,'OutDataTypeStr',labelInfo.DataType);
        set_param(dataBlkFullName,'Dimensions','1');
        set_param(dataBlkFullName,'InitialValue',labelInfo.InitialValue);
        set_param(dataBlkFullName,'DataStoreName',labelInfo.DSMDataName);
    end
    updateDataReset(routineBlock,labelInfo)
    updateLabelAssert(routineBlock,labelInfo)
end

function updateDataReset(routineBlock,labelInfo)
    dataParentBlk=get_param(routineBlock,'parent');
    dataResetBlkName=[labelInfo.DataName,'_LabelReset'];
    dataResetBlkFullName=[dataParentBlk,'/',dataResetBlkName];
    constantBlkName=[labelInfo.DataName,'_LabelInitValue'];
    constantBlkFullName=[dataParentBlk,'/',constantBlkName];

    if getSimulinkBlockHandle(dataResetBlkFullName)<=0

        dataWritePriority='11';
        safe_add_block('simulink/Signal Routing/Data Store Write',dataResetBlkFullName);
        set_param(dataResetBlkFullName,'Priority',dataWritePriority);
        set_param(dataResetBlkFullName,'DataStoreName',labelInfo.DSMDataName);
        safe_add_block('built-in/Constant',constantBlkFullName);
        set_param(constantBlkFullName,'OutDataTypeStr',labelInfo.DataType);
        set_param(constantBlkFullName,'Value',labelInfo.InitialValue);
        add_line(dataParentBlk,[constantBlkName,'/1'],[dataResetBlkName,'/1']);
    end
end

function updateLabelAssert(routineBlock,labelInfo)
    if~labelInfo.IsLabel
        return
    end
    dataParentBlk=get_param(routineBlock,'parent');
    labelAssertBlkName=[labelInfo.DataName,'_LabelAssert'];
    labelAssertBlkFullName=[dataParentBlk,'/',labelAssertBlkName];
    assertionBlkName=[labelInfo.DataName,'_AssertZero'];
    assertionBlkFullName=[dataParentBlk,'/',assertionBlkName];

    if getSimulinkBlockHandle(labelAssertBlkFullName)<=0

        dataWritePriority='20';
        safe_add_block('simulink/Signal Routing/Data Store Read',labelAssertBlkFullName);
        set_param(labelAssertBlkFullName,'Priority',dataWritePriority);
        set_param(labelAssertBlkFullName,'DataStoreName',labelInfo.DSMDataName);
        slplc.utils.addLibBlock('AssertZero',assertionBlkFullName);
        add_line(dataParentBlk,[labelAssertBlkName,'/1'],[assertionBlkName,'/1']);
    end
end

function dataNames=getExistentLabelDataNames(routineBlock)
    dataParentBlock=get_param(routineBlock,'parent');
    routineScopeTag=slplc.utils.getBlockScopeTag(routineBlock);
    dataBlocks=plc_find_system(dataParentBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name',['^_',routineScopeTag,'\w+_Label$']);
    dataNames=cell(numel(dataBlocks),1);
    for varCount=1:numel(dataBlocks)
        dataBlk=dataBlocks{varCount};
        dataNames{varCount}=regexprep(get_param(dataBlk,'Name'),'_Label$','');
    end
end

function formatDataBlocks(routineBlock)
    dataParentBlk=get_param(routineBlock,'parent');
    routineBlkPosition=get_param(routineBlock,'Position');
    baseline=[(routineBlkPosition(1)+routineBlkPosition(3))/2,routineBlkPosition(4)+75];
    yStep=60;

    dataBlockBasePosition=[baseline(1)-45,baseline(2)];

    routineScopeTag=slplc.utils.getBlockScopeTag(routineBlock);
    dataBlocks=plc_find_system(dataParentBlk,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name',['^_',routineScopeTag,'\w+_Label$']);

    for blkCount=1:numel(dataBlocks)
        dataBlockBasePosition=[dataBlockBasePosition(1),dataBlockBasePosition(2)+yStep];
        set_param(dataBlocks{blkCount},'Position',...
        [dataBlockBasePosition(1),dataBlockBasePosition(2),dataBlockBasePosition(1)+90,dataBlockBasePosition(2)+30]);
    end

    constantBlocks=plc_find_system(dataParentBlk,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name',['^_',routineScopeTag,'\w+_LabelInitValue$']);

    constantBlkBasePosition=[baseline(1)-500,baseline(2)+10];
    dataResetBlkBasePosition=[baseline(1)-300,baseline(2)];
    for blkCount=1:numel(constantBlocks)
        constantBlkBasePosition=[constantBlkBasePosition(1),constantBlkBasePosition(2)+yStep];
        dataResetBlkBasePosition=[dataResetBlkBasePosition(1),dataResetBlkBasePosition(2)+yStep];
        portConn=get_param(constantBlocks{blkCount},'PortConnectivity');
        set_param(constantBlocks{blkCount},'Position',[constantBlkBasePosition(1),constantBlkBasePosition(2),constantBlkBasePosition(1)+30,constantBlkBasePosition(2)+14]);
        set_param(portConn.DstBlock,'Position',[dataResetBlkBasePosition(1),dataResetBlkBasePosition(2),dataResetBlkBasePosition(1)+90,dataResetBlkBasePosition(2)+30]);
    end

    labelAssertBlocks=plc_find_system(dataParentBlk,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name',['^_',routineScopeTag,'\w+_LabelAssert$']);

    labelAssertBlkBasePosition=[baseline(1)+255,baseline(2)];
    assertionBlkBasePosition=[baseline(1)+455,baseline(2)];
    for blkCount=1:numel(labelAssertBlocks)
        labelAssertBlkBasePosition=[labelAssertBlkBasePosition(1),labelAssertBlkBasePosition(2)+yStep];
        assertionBlkBasePosition=[assertionBlkBasePosition(1),assertionBlkBasePosition(2)+yStep];
        portConn=get_param(labelAssertBlocks{blkCount},'PortConnectivity');
        set_param(labelAssertBlocks{blkCount},'Position',[labelAssertBlkBasePosition(1),labelAssertBlkBasePosition(2),labelAssertBlkBasePosition(1)+90,labelAssertBlkBasePosition(2)+30]);
        set_param(portConn.DstBlock,'Position',[assertionBlkBasePosition(1),assertionBlkBasePosition(2),assertionBlkBasePosition(1)+30,assertionBlkBasePosition(2)+30]);
    end

end

function blkH=safe_add_block(src,dst,varargin)
    blkH=-1;
    if getSimulinkBlockHandle(dst)<=0

        blkH=add_block(src,dst,varargin{:});
    end
end
