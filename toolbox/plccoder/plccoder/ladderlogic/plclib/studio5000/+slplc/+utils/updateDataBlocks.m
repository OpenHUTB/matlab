function updateDataBlocks(pouBlock)




    varList=slplc.utils.getVariableList(pouBlock);
    pouType=slplc.utils.getParam(pouBlock,'PLCPOUType');
    dataParentBlock=getDataParentBlock(pouBlock,pouType);

    existentVarNames=getExistentDataNames(dataParentBlock);
    if isempty(varList)
        toDeleteVarNames=existentVarNames;
    else
        toDeleteVarNames=setdiff(existentVarNames,{varList.Name});
    end
    for dataCount=1:numel(toDeleteVarNames)
        varName=toDeleteVarNames{dataCount};
        removeDataBlock(dataParentBlock,varName);
        removeVarInport(pouBlock,dataParentBlock,varName);
        removeVarOutport(pouBlock,dataParentBlock,varName);
    end

    for dataCount=1:numel(varList)
        varInfo=varList(dataCount);
        locUpdateDataBlks(pouBlock,pouType,dataParentBlock,varInfo);
    end

    formatDataBlocks(pouBlock,dataParentBlock);

    if strcmpi(pouType,'function block')||...
        strcmpi(pouType,'function')||...
        strcmpi(pouType,'subroutine')
        updateInterfacePorts(pouBlock);
    end

end

function dataNames=getExistentDataNames(dataParentBlock)
    dataBlocks=plc_find_system(dataParentBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name','_Data$',...
    'BlockType','DataStoreMemory');
    writeBlocks=plc_find_system(dataParentBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'PLCBlockType','VarWrite');
    readBlocks=plc_find_system(dataParentBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'PLCBlockType','VarRead');

    dataVarNames=cell(numel(dataBlocks),1);
    for varCount=1:numel(dataBlocks)
        dataBlk=dataBlocks{varCount};
        dataVarNames{varCount}=regexprep(get_param(dataBlk,'Name'),'_Data$','');
    end

    writeVarNames=cell(numel(writeBlocks),1);
    for varCount=1:numel(writeBlocks)
        writeBlk=writeBlocks{varCount};
        writeVarNames{varCount}=regexprep(get_param(writeBlk,'Name'),'_Write$','');
    end

    readVarNames=cell(numel(readBlocks),1);
    for varCount=1:numel(readBlocks)
        readBlk=readBlocks{varCount};
        readVarNames{varCount}=regexprep(get_param(readBlk,'Name'),'_Read$','');
    end

    dataNames=unique([dataVarNames;writeVarNames;readVarNames]);
end


function locUpdateDataBlks(pouBlock,pouType,dataParentBlock,varInfo)
    if strcmpi(pouType,'PLC Controller')
        if strcmpi(varInfo.Scope,'global')
            updateData(dataParentBlock,varInfo);
        else
            removeDataBlock(dataParentBlock,varInfo.Name);
        end
    elseif strcmpi(pouType,'Program')
        if~strcmpi(varInfo.Scope,'external')&&...
            ~strcmpi(varInfo.Scope,'inout')
            updateData(dataParentBlock,varInfo);
        else
            removeDataBlock(dataParentBlock,varInfo.Name);
        end
    elseif strcmpi(pouType,'Function Block')
        removeDataBlock(dataParentBlock,varInfo.Name);
    elseif strcmpi(pouType,'Function')
        if~strcmpi(varInfo.Scope,'external')&&...
            ~strcmpi(varInfo.Scope,'inout')
            updateData(dataParentBlock,varInfo);
        else
            removeDataBlock(dataParentBlock,varInfo.Name);
        end
    end

    if strcmpi(varInfo.PortType,'inport')
        if ismember(varInfo.Scope,{'Output','Local','External'})
            error('slplc:invalidInport',...
            'Invalid %s setting for %s scope of variable %s',...
            varInfo.PortType,varInfo.Scope,varInfo.Name);
        end
        removeVarOutport(pouBlock,dataParentBlock,varInfo.Name);
        updateVarInport(dataParentBlock,varInfo)
    elseif strcmpi(varInfo.PortType,'outport')
        if ismember(varInfo.Scope,{'Input','Local','External'})
            error('slplc:invalidInport',...
            'Invalid %s setting for %s scope of variable %s',...
            varInfo.PortType,varInfo.Scope,varInfo.Name);
        end
        removeVarInport(pouBlock,dataParentBlock,varInfo.Name);
        updateVarOutport(dataParentBlock,varInfo)
    elseif strcmpi(varInfo.PortType,'inport/outport')
        if~strcmpi(varInfo.Scope,'InOut')
            error('slplc:invalidInOutPort',...
            'Invalid %s setting for %s scope of variable %s',...
            varInfo.PortType,varInfo.Scope,varInfo.Name);
        end
        updateVarInport(dataParentBlock,varInfo);
        updateVarOutport(dataParentBlock,varInfo);
    else

        if ismember(varInfo.Scope,{'InOut'})
            error('slplc:invalidPortType',...
            'Invalid %s port setting for %s scope of variable %s',...
            varInfo.PortType,varInfo.Scope,varInfo.Name);
        end
        removeVarInport(pouBlock,dataParentBlock,varInfo.Name);
        removeVarOutport(pouBlock,dataParentBlock,varInfo.Name);
    end

end


function formatDataBlocks(pouBlock,dataParentBlk)
    baseline=[200,200];
    yStep=60;

    dataBlockBasePosition=[baseline(1)-45,baseline(2)];
    dataBlocks=plc_find_system(dataParentBlk,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'Name','_Data$',...
    'BlockType','DataStoreMemory');
    for blkCount=1:numel(dataBlocks)
        dataBlockBasePosition=[dataBlockBasePosition(1),dataBlockBasePosition(2)+yStep];
        set_param(dataBlocks{blkCount},'Position',...
        [dataBlockBasePosition(1),dataBlockBasePosition(2),dataBlockBasePosition(1)+90,dataBlockBasePosition(2)+30]);
    end

    logicBlkBasePosition=[baseline(1)-75,dataBlockBasePosition(2)+yStep];
    logicBlock=slplc.utils.getInternalBlockPath(pouBlock,'Logic');
    if isempty(logicBlock)
        return
    end

    set_param(logicBlock,'Position',...
    [logicBlkBasePosition(1),logicBlkBasePosition(2),logicBlkBasePosition(1)+150,logicBlkBasePosition(2)+200]);
    set_param(logicBlock,'Priority','12');

    enableInFalseBlock=slplc.utils.getInternalBlockPath(pouBlock,'_EnableInFalse');
    if getSimulinkBlockHandle(enableInFalseBlock)>0
        set_param(enableInFalseBlock,'Position',...
        [logicBlkBasePosition(1)+500,logicBlkBasePosition(2),logicBlkBasePosition(1)+650,logicBlkBasePosition(2)+200]);
        set_param(enableInFalseBlock,'Priority','12');
    end

    enableInOutBlock=slplc.utils.getInternalBlockPath(pouBlock,'_EnableInOut');
    if getSimulinkBlockHandle(enableInOutBlock)>0
        set_param(enableInOutBlock,'Priority','12');
    end

    inportBlocks=plc_find_system(dataParentBlk,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'BlockType','Inport');

    inportBasePosition=[baseline(1)-300,baseline(2)+10];
    dataWriteBasePosition=[baseline(1)-200,baseline(2)];
    for blkCount=1:numel(inportBlocks)
        inportBasePosition=[inportBasePosition(1),inportBasePosition(2)+yStep];
        dataWriteBasePosition=[dataWriteBasePosition(1),dataWriteBasePosition(2)+yStep];
        portConn=get_param(inportBlocks{blkCount},'PortConnectivity');
        set_param(inportBlocks{blkCount},'Position',[inportBasePosition(1),inportBasePosition(2),inportBasePosition(1)+30,inportBasePosition(2)+14]);
        dstBlocks=portConn.DstBlock;
        for dstBlkCount=1:numel(dstBlocks)
            plcBlockType=slplc.utils.getParam(dstBlocks(dstBlkCount),'PLCBlockType');
            if ischar(plcBlockType)&&ismember(plcBlockType,{'VarWrite','RefWrite'})
                set_param(dstBlocks(dstBlkCount),'Position',...
                [dataWriteBasePosition(1),dataWriteBasePosition(2),dataWriteBasePosition(1)+90,dataWriteBasePosition(2)+30]);
            end
        end
    end

    outportBlocks=plc_find_system(dataParentBlk,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'BlockType','Outport');
    outportBasePosition=[baseline(1)+270,baseline(2)+10];
    dataReadBasePosition=[baseline(1)+110,baseline(2)];
    for blkCount=1:numel(outportBlocks)
        outportBasePosition=[outportBasePosition(1),outportBasePosition(2)+yStep];
        dataReadBasePosition=[dataReadBasePosition(1),dataReadBasePosition(2)+yStep];
        portConn=get_param(outportBlocks{blkCount},'PortConnectivity');
        set_param(outportBlocks{blkCount},'Position',[outportBasePosition(1),outportBasePosition(2),outportBasePosition(1)+30,outportBasePosition(2)+14]);
        set_param(portConn.SrcBlock,'Position',[dataReadBasePosition(1),dataReadBasePosition(2),dataReadBasePosition(1)+90,dataReadBasePosition(2)+30]);
    end

end

function updateData(dataParentBlk,varInfo)
    msgSetting='none';
    priority='10';
    dataBlkFullName=[dataParentBlk,'/',varInfo.Name,'_Data'];
    if getSimulinkBlockHandle(dataBlkFullName)<=0

        safe_add_block('simulink/Signal Routing/Data Store Memory',dataBlkFullName);
        set_param(dataBlkFullName,'WriteAfterReadMsg',msgSetting);
        set_param(dataBlkFullName,'ReadBeforeWriteMsg',msgSetting);
        set_param(dataBlkFullName,'WriteAfterWriteMsg',msgSetting);
        set_param(dataBlkFullName,'Priority',priority);
        set_param(dataBlkFullName,'Tag','POUVariable');
        set_param(dataBlkFullName,'SignalType','real');
    end

    set_param(dataBlkFullName,'OutDataTypeStr',varInfo.DataType);
    set_param(dataBlkFullName,'Dimensions',varInfo.Size);

    initValue=varInfo.InitialValue;
    if contains(lower(initValue),'t#')
        if strcmpi(varInfo.DataType,'time')

            initValue=slplc.callbacks.getTimeDuration(initValue);
        else
            error('slplc:wrongInitialValue','Wrong initial value %s (time format) for data type %s',initValue,varInfo.DataType);
        end
    end
    set_param(dataBlkFullName,'InitialValue',initValue);


    dsmDataName=slplc.utils.getVariableDSMNames(varInfo.Name);
    set_param(dataBlkFullName,'DataStoreName',dsmDataName);
end

function updateVarInport(dataParentBlk,varInfo)
    dataWriteBlkName=[varInfo.Name,'_Write'];
    dataWriteBlkFullName=[dataParentBlk,'/',dataWriteBlkName];

    inportName=getPortName(varInfo,'inport');
    inportFullName=[dataParentBlk,'/',inportName];
    dataWritePriority='11';

    coreLibName=slplc.utils.getCoreLibName();
    if~bdIsLoaded(coreLibName)
        load_system(coreLibName);
    end
    if strcmpi(varInfo.Scope,'inout')
        libBlk=[coreLibName,'/RefWrite'];
    else
        libBlk=[coreLibName,'/VarWrite'];
    end

    newAddedDWB=safe_add_block(libBlk,dataWriteBlkFullName);
    set_param(dataWriteBlkFullName,'PLCOperandTag',varInfo.Name);
    dataBlkConn=get_param(dataWriteBlkFullName,'PortConnectivity');
    inportBlkH=dataBlkConn.SrcBlock;

    if inportBlkH<=0

        newAddedInPortBlk=safe_add_block('built-in/Inport',inportFullName);
        if newAddedDWB>0&&newAddedInPortBlk<0
            inportLineH=get_param(inportFullName,'LineHandles');
            if inportLineH.Outport>0
                delete_line(inportLineH.Outport)
            end
        end
        add_line(dataParentBlk,[inportName,'/1'],[dataWriteBlkName,'/1']);
    else
        dataWriteBlkType=get_param(dataWriteBlkFullName,'PLCBlockType');
        if(strcmpi(dataWriteBlkType,'VarWrite')&&strcmpi(varInfo.Scope,'inout'))||...
            (strcmpi(dataWriteBlkType,'RefWrite')&&strcmpi(varInfo.Scope,'input'))

            replBlk=replace_block(dataParentBlk,'SearchDepth',1,...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'Name',dataWriteBlkName,...
            libBlk,'noprompt');
            set_param(replBlk{1},'Name',dataWriteBlkName);
            set_param(replBlk{1},'PLCOperandTag',varInfo.Name);
        end
        if getSimulinkBlockHandle(inportFullName)<=0

            set_param(inportBlkH,'Name',inportName);
        end
    end



    set_param(dataWriteBlkFullName,'Priority',dataWritePriority);
    set_param(inportFullName,'Port',varInfo.PortIndex);
    set_param(inportFullName,'OutDataTypeStr',varInfo.DataType);
end

function updateVarOutport(dataParentBlk,varInfo)
    dataReadBlkName=[varInfo.Name,'_Read'];
    dataReadBlkFullName=[dataParentBlk,'/',dataReadBlkName];

    outportName=getPortName(varInfo,'outport');
    outportFullName=[dataParentBlk,'/',outportName];
    dataReadPriority='13';

    coreLibName=slplc.utils.getCoreLibName();
    safe_add_block([coreLibName,'/VarRead'],dataReadBlkFullName);
    set_param(dataReadBlkFullName,'PLCOperandTag',varInfo.Name);
    dataBlkConns=get_param(dataReadBlkFullName,'PortConnectivity');
    outportBlkH=dataBlkConns.DstBlock;

    if isempty(outportBlkH)

        safe_add_block('built-in/Outport',outportFullName);
        add_line(dataParentBlk,[dataReadBlkName,'/1'],[outportName,'/1']);
    else

        if getSimulinkBlockHandle(outportFullName)<=0
            set_param(outportBlkH,'Name',outportName);
        end
    end
    set_param(dataReadBlkFullName,'Priority',dataReadPriority);
    set_param(outportFullName,'Port',varInfo.PortIndex);
end


function removeDataBlock(dataParentBlk,dataName)
    dataBlk=[dataParentBlk,'/',dataName,'_Data'];
    if getSimulinkBlockHandle(dataBlk)>0
        delete_block(dataBlk);
    end
end

function removeVarInport(pouBlock,dataParentBlk,varName)
    if strcmp(pouBlock,get_param(dataParentBlk,'Parent'))
        inportFullName=[pouBlock,'/',varName];
        if getSimulinkBlockHandle(inportFullName)>0&&strcmpi(get_param(inportFullName,'BlockType'),'Inport')
            inportBlkH=get_param(inportFullName,'LineHandles');
            if~isempty(inportBlkH)&&~isempty(inportBlkH.Outport)&&inportBlkH.Outport(1)>0
                delete_line(inportBlkH.Outport(1));
            end
            delete_block(inportFullName);
        end
    end
    dataWriteBlk=[dataParentBlk,'/',varName,'_Write'];
    removeVarPort(dataWriteBlk);
end

function removeVarOutport(pouBlock,dataParentBlk,varName)
    if strcmp(pouBlock,get_param(dataParentBlk,'Parent'))

        outportBlks=plc_find_system(pouBlock,...
        'SearchDepth',1,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'regexp','on',...
        'Name',['^\s*',varName,'$']);
        for portCount=1:numel(outportBlks)
            if strcmpi(get_param(outportBlks{portCount},'BlockType'),'Outport')
                outportBlkH=get_param(outportBlks{portCount},'LineHandles');
                if~isempty(outportBlkH)&&~isempty(outportBlkH.Inport)&&outportBlkH.Inport(1)>0
                    delete_line(outportBlkH.Inport(1));
                end
                delete_block(outportBlks{portCount});
            end
        end
    end
    dataReadBlk=[dataParentBlk,'/',varName,'_Read'];
    removeVarPort(dataReadBlk);
end

function removeVarPort(dataReadWriteBlkFullName)
    if getSimulinkBlockHandle(dataReadWriteBlkFullName)<=0
        return
    end
    blkConn=get_param(dataReadWriteBlkFullName,'PortConnectivity');
    srcBlk=blkConn.SrcBlock;
    DstBlocks=blkConn.DstBlock;
    if srcBlk>0
        DstBlocks=get_param(dataReadWriteBlkFullName,'handle');
    elseif~isempty(DstBlocks)
        srcBlk=get_param(dataReadWriteBlkFullName,'handle');
    end
    if srcBlk>0
        srcBlkName=get_param(srcBlk,'Name');
        block=get_param(dataReadWriteBlkFullName,'Parent');
        for dstCount=1:numel(DstBlocks)
            DstBlock=DstBlocks(dstCount);
            DstBlockName=get_param(DstBlock,'Name');
            delete_line(block,[srcBlkName,'/1'],[DstBlockName,'/1']);
            delete_block(DstBlock);
        end
        delete_block(srcBlk);
    end
end

function portName=getPortName(varInfo,portType)
    if isempty(varInfo.Address)||strcmpi(varInfo.Address,'<empty>')
        portName=varInfo.Name;
    else
        portName=[varInfo.Name,' At ',varInfo.Address];
    end
    if strcmpi(varInfo.Scope,'inout')&&strcmpi(portType,'Outport')
        portName=[' ',portName];
    end
end

function dataParentBlock=getDataParentBlock(pouBlock,pouType)
    if strcmpi(pouType,'function block')||...
        strcmpi(pouType,'function')||...
        strcmpi(pouType,'subroutine')
        dataParentBlock=slplc.utils.getInternalBlockPath(pouBlock,'Enable');
    else
        dataParentBlock=pouBlock;
    end
end

function updateInterfacePorts(pouBlock)
    enableBlock=slplc.utils.getInternalBlockPath(pouBlock,'Enable');
    enableBlockName=get_param(enableBlock,'Name');
    portConns=get_param(enableBlock,'PortConnectivity');
    portType='Inport';
    previouPortNum=0;

    for connCount=1:numel(portConns)
        currentConn=portConns(connCount);
        portNumOrType=currentConn.Type;
        if strcmpi(portNumOrType,'enable')
            portType='Outport';
            continue
        elseif str2double(portNumOrType)<=previouPortNum
            portType='Outport';
        end
        portsInEnableBlock=plc_find_system(enableBlock,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType',portType,'Port',portNumOrType);
        portInEnableBlock=portsInEnableBlock{1};
        portName=get_param(portInEnableBlock,'Name');

        if strcmp(portName,'EnableIn')
            rungInPortFullName=[pouBlock,'/','RungIn'];

            runtInportPosition=get_param(rungInPortFullName,'Position');
            rungInportCenterY=(runtInportPosition(2)+runtInportPosition(4))/2;
            connPosition=currentConn.Position;
            yDistance=rungInportCenterY-connPosition(2);

            if yDistance~=0
                enableBlockPosition=get_param(enableBlock,'Position');
                newEnableBlockPosition=[enableBlockPosition(1),enableBlockPosition(2)+yDistance,enableBlockPosition(3),enableBlockPosition(4)+yDistance];
                set_param(enableBlock,'Position',newEnableBlockPosition);
                portConns=get_param(enableBlock,'PortConnectivity');

                preScanBlk=slplc.utils.getInternalBlockPath(pouBlock,'Prescan');
                if~isempty(preScanBlk)&&getSimulinkBlockHandle(preScanBlk)>0
                    prescanBlockPosition=get_param(preScanBlk,'Position');
                    newPrescanBlockPosition=[prescanBlockPosition(1),prescanBlockPosition(2)+yDistance,prescanBlockPosition(3),prescanBlockPosition(4)+yDistance];
                    set_param(preScanBlk,'Position',newPrescanBlockPosition);
                end
            end

            previouPortNum=str2double(portNumOrType);
            continue
        elseif strcmp(portName,'EnableOut')
            previouPortNum=str2double(portNumOrType);
            continue
        end

        portFullName=[pouBlock,'/',portName];
        if strcmpi(portType,'Inport')
            if currentConn.SrcBlock<0
                safe_add_block('built-in/Inport',portFullName);
                add_line(pouBlock,[portName,'/1'],[enableBlockName,'/',portNumOrType]);
            end
            connPosition=currentConn.Position;
            portPosition=[connPosition(1)-100,connPosition(2)-7,connPosition(1)-70,connPosition(2)+7];
            set_param(portFullName,'Port',portNumOrType);
            set_param(portFullName,'Position',portPosition);
        elseif strcmpi(portType,'Outport')
            if isempty(currentConn.DstBlock)||(isscalar(currentConn.DstBlock)&&currentConn.DstBlock<=0)
                safe_add_block('built-in/Outport',portFullName);
                add_line(pouBlock,[enableBlockName,'/',portNumOrType],[portName,'/1']);
            end
            connPosition=currentConn.Position;
            portPosition=[connPosition(1)+70,connPosition(2)-7,connPosition(1)+100,connPosition(2)+7];
            set_param(portFullName,'Port',portNumOrType);
            set_param(portFullName,'Position',portPosition);
        end
        previouPortNum=str2double(portNumOrType);
    end

    rungInBlk=[pouBlock,'/RungIn'];
    if getSimulinkBlockHandle(rungInBlk)>0
        blockType=get_param(rungInBlk,'BlockType');
        if strcmpi(blockType,'Inport')
            set_param(rungInBlk,'Port','1');
        end
    end

    rungOutBlk=[pouBlock,'/RungOut'];
    if getSimulinkBlockHandle(rungOutBlk)>0
        blockType=get_param(rungOutBlk,'BlockType');
        if strcmpi(blockType,'Outport')
            set_param(rungOutBlk,'Port','1');
        end
    end

end

function blkH=safe_add_block(src,dst,varargin)
    blkH=-1;
    if getSimulinkBlockHandle(dst)<=0

        blkH=add_block(src,dst,varargin{:});
    end
end


