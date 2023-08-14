function addDataIOBlocks(topModel,topSysMdl)














































    if ishandle(topModel)
        topModel=get_param(topModel,'Name');
    end
    load_system(topModel);
    load_system('prociodatalib');
    closeLibrary=onCleanup(@()close_system('prociodatalib'));
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        [~,refBlks]=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.activeVariants);
    else
        [~,refBlks]=find_mdlrefs(topModel,'Variants','ActiveVariants');
    end
    taskMgr=soc.internal.connectivity.getTaskManagerBlock(topModel);
    if~iscell(taskMgr)
        taskMgr={taskMgr};
    end
    for i=1:numel(taskMgr)
        portH=get_param(taskMgr{i},'LineHandles');
        allLineHandles=portH.Outport;
        allModelRefs=arrayfun(@(x)get_param(get_param(x,'NonVirtualDstPorts'),'Parent'),allLineHandles,'UniformOutput',false);
        refBlks=unique(allModelRefs);
        addDataIOBlocksCore(topModel,topSysMdl,taskMgr{i},refBlks);
    end
end


function addDataIOBlocksCore(topModel,topSysMdl,taskMgr,refBlks)
    taskMgrPos=get_param(taskMgr,'Position');
    taskMgrInPorts=find_system(taskMgr,'FollowLinks','on','SearchDepth',1,...
    'LookUnderMasks','on','BlockType','Inport');
    taskMgrPortHandles=get_param(taskMgr,'PortHandles');
    taskMgrInportHandles=taskMgrPortHandles.Inport;
    for refBlkIter=1:numel(refBlks)
        thisRefBlk=refBlks{refBlkIter};
        theRefModel=get_param(thisRefBlk,'ModelName');
        load_system(thisRefBlk);

        processorIOBlks=loc_getAllIOBlocks(theRefModel);
        processsorInterconnectBlks=loc_getAllInterconnectBlocks(theRefModel);

        drvPeriphBlks=l_getPeripheralBlocks(theRefModel);

        ioPeriphBlks=[processorIOBlks;processsorInterconnectBlks;drvPeriphBlks];
        for ioBlockIter=1:numel(ioPeriphBlks)
            thisBlkHandle=get_param(ioPeriphBlks{ioBlockIter},'handle');
            [dataType,dataDim,deviceType,queueLength,hasIOPort]=loc_getParametersForIOBlock(thisBlkHandle);
            if~hasIOPort
                continue;
            end
            [topModelDataPort,topModelDataAckPort,eventName]=loc_getPortInfoForIOBlock(thisBlkHandle,thisRefBlk,topModel,topSysMdl);
            [~,blockType]=fileparts(get_param(thisBlkHandle,'ReferenceBlock'));
            if any(strcmpi(blockType,{'Stream Read','Register Read','Interprocess Data Read','ADC Read'}))

                dataSourceBlkName=sprintf('%s/IODataSource_%s',topModel,deviceType);
                thisIODataSrcBlk=add_block('prociodatalib/IO Data Source',dataSourceBlkName,'MakeNameUnique','on','Position',taskMgrPos);

                set_param(thisIODataSrcBlk,'DeviceType',deviceType);
                set_param(thisIODataSrcBlk,'InputSource','From dialog');
                set_param(thisIODataSrcBlk,'SampleTime','inf');

                try
                    realDataType=evalin('base',dataType);
                    switch class(realDataType)
                    case 'Simulink.NumericType'
                        ioDataSrcValue=sprintf('fi(ones(1, %s),%s)',dataDim,dataType);
                    case 'Simulink.AliasType'
                        try
                            evalin('base',realDataType.BaseType);
                            ioDataSrcValue=sprintf('fi(ones(1, %s),%s)',dataDim,realDataType.BaseType);
                        catch

                            ioDataSrcValue=sprintf('%s(ones(1, %s))',realDataType.BaseType,dataDim);
                        end
                    end
                catch

                    if(startsWith(dataType,'Bus: '))
                        ioDataSrcValue=sprintf('Simulink.Bus.createMATLABStruct(''%s'')',extractAfter(dataType,'Bus: '));

                        set_param([dataSourceBlkName,'/Variant/SIM/Source Variant/From Constant/data'],'OutDataTypeStr',dataType);
                    else
                        ioDataSrcValue=sprintf('%s(ones(1, %s))',dataType,dataDim);
                    end
                end
                set_param(thisIODataSrcBlk,'Value',ioDataSrcValue);
                if isempty(eventName)
                    set_param(thisIODataSrcBlk,'EventDataPort','Data');
                else
                    set_param(thisIODataSrcBlk,'EventDataPort','Data and Event');
                end
                if~isempty(queueLength)
                    set_param(thisIODataSrcBlk,'QueueLength',queueLength);
                end

                if~isempty(topModelDataAckPort)

                    dataAckPortConnectivity=get_param(topModelDataAckPort,'PortConnectivity');
                    delete_block(topModelDataAckPort);
                    src=dataAckPortConnectivity(1).Position;

                    dst=l_getPortPositionByName(thisIODataSrcBlk,'done');

                    wayPoint=[src(1),dst(2)];
                    add_line(topModel,[src;wayPoint;dst]);
                end

                if~isempty(eventName)

                    taskEvtPort=taskMgrInportHandles(contains(taskMgrInPorts,eventName));
                    eventPort=get_param(get_param(get_param(taskEvtPort,'Line'),'NonVirtualSrcPorts'),'Parent');
                    eventPortConnectivity=get_param(eventPort,'PortConnectivity');
                    delete_block(eventPort);
                    dst=eventPortConnectivity(1).Position;

                    src=l_getPortPositionByName(thisIODataSrcBlk,'event');

                    wayPoint=[src(1),dst(2)];
                    add_line(topModel,[src;wayPoint;dst]);
                end


                if~isempty(topModelDataPort)
                    dataPortConnectivity=get_param(topModelDataPort,'PortConnectivity');
                    delete_block(topModelDataPort);
                    dst=dataPortConnectivity(1).Position;

                    src=l_getPortPositionByName(thisIODataSrcBlk,'msg');

                    wayPoint=[src(1),dst(2)];
                    add_line(topModel,[src;wayPoint;dst]);




                    pos=taskMgrPos;
                    pos(2)=pos(2)-100*ioBlockIter;
                    pos(4)=pos(4)-100*ioBlockIter;
                    set_param(thisIODataSrcBlk,'Position',pos);
                end
            elseif any(strcmpi(blockType,{'Stream Write','Register Write','Interprocess Data Write','PWM Write'}))

                dataSinkBlkName=sprintf('%s/IODataSink_%s',topModel,deviceType);
                thisIODataSinkBlk=add_block('prociodatalib/IO Data Sink',dataSinkBlkName,'MakeNameUnique','on','Position',taskMgrPos);

                set_param(thisIODataSinkBlk,'DeviceType',deviceType);
                set_param(thisIODataSinkBlk,'OutputSink','To terminator');
                set_param(thisIODataSinkBlk,'SampleTime','-1');
                if isempty(eventName)
                    set_param(thisIODataSinkBlk,'EventDataPort','Data');
                else
                    set_param(thisIODataSinkBlk,'EventDataPort','Data and Event');
                end
                if~isempty(queueLength)
                    set_param(thisIODataSinkBlk,'QueueLength',queueLength);
                end


                if~isempty(topModelDataAckPort)

                    dataAckPortConnectivity=get_param(topModelDataAckPort,'PortConnectivity');
                    delete_block(topModelDataAckPort);
                    dst=dataAckPortConnectivity(1).Position;

                    src=l_getPortPositionByName(thisIODataSinkBlk,'done');

                    wayPoint=[src(1),dst(2)];
                    add_line(topModel,[src;wayPoint;dst]);
                end

                if~isempty(eventName)

                    taskEvtPort=taskMgrInportHandles(contains(taskMgrInPorts,eventName));
                    eventPort=get_param(get_param(get_param(taskEvtPort,'Line'),'NonVirtualSrcPorts'),'Parent');
                    eventPortConnectivity=get_param(eventPort,'PortConnectivity');
                    delete_block(eventPort);
                    dst=eventPortConnectivity(1).Position;

                    src=l_getPortPositionByName(thisIODataSinkBlk,'event');

                    wayPoint=[src(1),dst(2)];
                    add_line(topModel,[src;wayPoint;dst]);
                end


                if~isempty(topModelDataPort)
                    dataPortConnectivity=get_param(topModelDataPort,'PortConnectivity');
                    delete_block(topModelDataPort);
                    src=dataPortConnectivity(1).Position;

                    dst=l_getPortPositionByName(thisIODataSinkBlk,'msg');

                    wayPoint=[src(1),dst(2)];
                    add_line(topModel,[src;wayPoint;dst]);




                    pos=taskMgrPos;
                    pos(2)=pos(2)-100*ioBlockIter;
                    pos(4)=pos(4)-100*ioBlockIter;
                    set_param(thisIODataSinkBlk,'Position',pos);
                end
            end
        end
    end
end

function ret=loc_getAllIOBlocks(thisModel)



    io_peripheral_blocks=find_system(thisModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','ReferenceBlock','prociolib*');
    blk_indx=cellfun(@(x)(contains(get_param(x,'ReferenceBlock'),'Stream','IgnoreCase',true)),io_peripheral_blocks)...
    |cellfun(@(x)(contains(get_param(x,'ReferenceBlock'),'Register','IgnoreCase',true)),io_peripheral_blocks);
    ret=io_peripheral_blocks(blk_indx);
end

function[topModelDataPort,topModelDataAckPort,eventName]=loc_getPortInfoForIOBlock(thisBlkHandle,thisRefBlk,topModel,topSysMdl)
    [dataPortHandle,dataAckPortHandle,supportsEventGen]=loc_getPortHandlesForBlock(thisBlkHandle,topSysMdl);
    topModelDataPort=[];
    topModelDataAckPort=[];
    eventName='';
    if ishandle(dataPortHandle)

        topModelDataAckPort=[];
        modelRefBlkPortHandles=get_param(thisRefBlk,'PortHandles');

        if strcmpi(get_param(dataPortHandle,'PortType'),'inport')
            dataPortDirection='NonVirtualSrcPorts';
            dataAckPortDirection='NonVirtualDstPorts';
            dataPortType='Inport';
            dataAckPortType='Outport';
        else
            dataPortDirection='NonVirtualDstPorts';
            dataAckPortDirection='NonVirtualSrcPorts';
            dataPortType='Outport';
            dataAckPortType='Inport';
        end
        lineHandle=get_param(dataPortHandle,'Line');
        if ishandle(lineHandle)&&(lineHandle~=-1)
            modelRefDataPortStr=get_param(...
            get_param(...
            get_param(...
            get_param(dataPortHandle,'Line'),...
            dataPortDirection),...
            'Parent'),...
            'Port');

            portHandles=modelRefBlkPortHandles.(dataPortType);
            modelRefBlkDataPort=portHandles(str2double(modelRefDataPortStr));
            topModelDataPort=get_param(get_param(get_param(modelRefBlkDataPort,'Line'),dataPortDirection),'Parent');
            if~isempty(dataAckPortHandle)
                modelRefDataAckPortStr=get_param(...
                get_param(...
                get_param(...
                get_param(dataAckPortHandle,'Line'),...
                dataAckPortDirection),...
                'Parent'),...
                'Port');
                portHandles=modelRefBlkPortHandles.(dataAckPortType);
                modelRefBlkDataAckPort=portHandles(str2double(modelRefDataAckPortStr));
                topModelDataAckPort=get_param(get_param(get_param(modelRefBlkDataAckPort,'Line'),dataAckPortDirection),'Parent');
            end

            eventName='';
            if supportsEventGen
                try
                    [~,eventName]=soc.internal.connectivity.getTaskNameForFcnCallSubs(thisBlkHandle,topModel);
                catch ME %#ok<NASGU>
                end
            end
        end
    end
end

function[dataType,dataDim,deviceType,queueLength,hasIOPort]=loc_getParametersForIOBlock(thisBlkHandle)
    dataType=[];
    dataDim=[];
    queueLength=[];
    hasIOPort=true;
    [~,blockType]=fileparts(get_param(thisBlkHandle,'ReferenceBlock'));
    switch(blockType)
    case 'Stream Read'
        dataType=get_param(thisBlkHandle,'OutDataTypeStr');
        dataDim=get_param(thisBlkHandle,'SamplesPerFrame');
        deviceType='Stream';
        queueLength=get_param(thisBlkHandle,'NumberOfBuffers');
    case 'Stream Write'
        deviceType='Stream';
        queueLength=get_param(thisBlkHandle,'NumberOfBuffers');

    case 'Register Read'
        dataType=get_param(thisBlkHandle,'OutDataTypeStr');
        dataDim=get_param(thisBlkHandle,'OutputVectorSize');
        deviceType='Register';
    case 'Register Write'
        deviceType='Register';
        hasIOPort=strcmp(get_param(thisBlkHandle,'OutputSink'),'To output port');
    case 'UDP Read'
        dataType=get_param(thisBlkHandle,'DataType');
        dataDim=get_param(thisBlkHandle,'DataLength');
        deviceType='UDP';
    case 'UDP Write'
        deviceType='UDP';

    case 'TCP Read'
        dataType=get_param(thisBlkHandle,'DataType');
        dataDim=get_param(thisBlkHandle,'DataLength');
        deviceType='TCP';
    case 'TCP Write'
        deviceType='TCP';

    case 'Interprocess Data Read'
        dataType=get_param(thisBlkHandle,'DataType');
        dataDim=get_param(thisBlkHandle,'DataLength');
        deviceType='Register';
    case 'Interprocess Data Write'
        deviceType='Register';
    case 'ADC Read'
        deviceType='Register';
        dataDim='1';
        dataType=get_param(thisBlkHandle,'DataType');
    case 'PWM Write'
        deviceType='Register';
    otherwise
        MSLE=MSLException(thisBlkHandle,message('soc:utils:BlockNotSupported',getfullname(thisBlkHandle)));
        throwAsCaller(MSLE);
    end
end

function[dataPortHandle,donePortHandle,supportsEventGen]=loc_getPortHandlesForBlock(thisBlkHandle,topSysMdl)


    donePortHandle=[];
    thisBlkPortHandles=get_param(thisBlkHandle,'PortHandles');
    [~,blockType]=fileparts(get_param(thisBlkHandle,'ReferenceBlock'));
    switch(blockType)
    case 'Stream Read'
        dataPortHandle=thisBlkPortHandles.Inport(1);
        donePortHandle=thisBlkPortHandles.Outport(3);
        supportsEventGen=isequal(get_param(thisBlkHandle,'EnableEvent'),'on');
    case 'Stream Write'
        dataPortHandle=thisBlkPortHandles.Outport(1);
        donePortHandle=thisBlkPortHandles.Inport(2);
        supportsEventGen=isequal(get_param(thisBlkHandle,'EnableEvent'),'on');
    case 'Register Read'
        dataPortHandle=thisBlkPortHandles.Inport(1);
        supportsEventGen=false;
    case 'Register Write'
        dataPortHandle=thisBlkPortHandles.Outport(1);
        supportsEventGen=false;
    case 'UDP Read'
        dataPortHandle=thisBlkPortHandles.Inport(1);
        supportsEventGen=isequal(get_param(thisBlkHandle,'EnableEvent'),'on');
    case 'UDP Write'
        dataPortHandle=thisBlkPortHandles.Outport(1);
        supportsEventGen=false;
    case 'TCP Read'
        dataPortHandle=thisBlkPortHandles.Inport(1);
        supportsEventGen=isequal(get_param(thisBlkHandle,'EnableEvent'),'on');
    case 'TCP Write'
        dataPortHandle=thisBlkPortHandles.Outport(1);
        supportsEventGen=false;
    case 'Interprocess Data Read'
        dataPortHandle=thisBlkPortHandles.Inport(1);
        supportsEventGen=l_ipcChannelUseEvent(thisBlkHandle,topSysMdl);
    case 'Interprocess Data Write'
        dataPortHandle=thisBlkPortHandles.Outport(1);
        supportsEventGen=false;
    case 'ADC Read'
        dataPortHandle=thisBlkPortHandles.Inport(1);
        supportsEventGen=l_adcReadUseEvents(thisBlkHandle,topSysMdl);
    case 'PWM Write'
        dataPortHandle=thisBlkPortHandles.Outport(1);
        supportsEventGen=false;
    otherwise
        MSLE=MSLException(thisBlkHandle,message('soc:utils:BlockNotSupported',getfullname(thisBlkHandle)));
        throwAsCaller(MSLE);
    end
end

function pos=l_getPortPositionByName(blkH,portName)
    allPorts=get_param(blkH,'PortHandles');
    portBlkHandle=find_system(blkH,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','Name',portName);
    portBlkNum=get_param(portBlkHandle,'Port');
    portType=get_param(portBlkHandle,'BlockType');
    portH=allPorts.(portType)(str2double(portBlkNum));
    pos=get_param(portH,'Position');
end

function ret=loc_getAllInterconnectBlocks(mdl)


    blks=find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','ReferenceBlock','procinterlib*');
    idx=cellfun(@(x)(contains(get_param(x,'ReferenceBlock'),...
    'Interprocess Data','IgnoreCase',true)),blks);
    ret=blks(idx);
end

function ret=l_getPeripheralBlocks(mdl)
    drvPeriphBlksList={'ADC Read','PWM Write'};

    findInLib='prociolib';
    drvBlks=[];
    for blkTypeIdx=1:numel(drvPeriphBlksList)


        blks=find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','ReferenceBlock',[findInLib,'*'],'MaskType',drvPeriphBlksList{blkTypeIdx});
        if~isempty(blks)
            drvBlks=[drvBlks;blks];%#ok<AGROW>
        end
    end

    ret=drvBlks;
end

function res=l_ipcChannelUseEvent(thisBlkHandle,topSysMdl)
    res=false;
    ipcChInfo=soc.internal.connectivity.findIPCCh2IPCRdPairs(topSysMdl);
    for i=1:numel(ipcChInfo)
        ipcReadHdl=get_param(ipcChInfo{i}.ipcread,'Handle');
        if isequal(thisBlkHandle,ipcReadHdl)
            val=get_param(ipcChInfo{i}.ipcchannel,'showEventPort');
            res=isequal(val,'on');
            return
        end
    end
end

function res=l_adcReadUseEvents(thisBlkHandle,topSysMdl)
    res=false;
    adcIfInfo=soc.internal.connectivity.findAdcReadPairs(topSysMdl);
    for i=1:numel(adcIfInfo)
        adcReadHdl=get_param(adcIfInfo{i}.adcread,'Handle');
        if isequal(thisBlkHandle,adcReadHdl)
            outPortHandles=soc.internal.connectivity.getSubsystemConnectedOutputPorts(adcIfInfo{i}.adcinterface);
            outPortNames=soc.internal.connectivity.getSystemOutputPorts(adcIfInfo{i}.adcinterface);
            EvtPort=contains(outPortNames,'Event','IgnoreCase',true);
            if any(EvtPort)
                EvtPortHdl=outPortHandles(EvtPort);
                taskblk=soc.internal.connectivity.getTaskManagerBlock(EvtPortHdl.DstBlock,'overrideAssert');
                res=~isempty(taskblk);
            end

            return;
        end
    end
end


