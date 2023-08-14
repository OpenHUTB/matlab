function undoCreateSubsystem(subSys)

    mdlName=Simulink.SimplifyModel.getSubsystemName(subSys);
    load_system(mdlName);

    referredModel='';
    if strcmp(get_param(subSys,'BlockType'),'ModelReference')
        referredModel=get_param(subSys,'ModelName');
        if~bdIsLoaded(referredModel)
            load_system(referredModel);
        end
    end



    [ioBlks_list,srcList,prtList]=Simulink.SimplifyModel.getSubsystemConnections(subSys);


    if~isempty(referredModel)
        getCommonDataSource(referredModel,mdlName);
        [oldPortHandles,oldBlockHandles]=get_portHandles(referredModel);
    else
        [oldPortHandles,oldBlockHandles]=get_portHandles(subSys);
    end
    portHandlesInParent=get_portHandles(get_param(subSys,'Parent'));
    newPortHandles={};

    blockTypeList={'ForEach','WhileIterator','ForIterator','EnablePort','TriggerPort','StatePort','PMIOPort','PMIOPort','ActionPort'};

    oldPortHandlesWithoutIO={};
    signalProps={'DataLogging','DataLoggingDecimateData','DataLoggingDecimation','DataLoggingLimitDataPoints','DataLoggingMaxPoints',...
    'DataLoggingName','DataLoggingNameMode','SignalNameFromLabel','MustResolveToSignalObject','Name',...
    'RTWStorageClass','RTWStorageTypeQualifier','ShowPropagatedSignals','SignalObject','TestPoint'};

    Simulink.SimplifyModel.removeUnconnectedLines(get_param(subSys,'Parent'));

    for i=1:length(oldBlockHandles)
        subsysPortIsConnected=false;

        if strcmp(get_param(oldBlockHandles{i},'BlockType'),'Inport')
            for j=1:length(ioBlks_list.Inport)
                for k=1:length(ioBlks_list.Inport{j})
                    blkName=ioBlks_list.Inport{j}{k};
                    if get_param(blkName,'Handle')==oldBlockHandles{i}&&~isempty(srcList)&&isfield(srcList,'Inport')&&~isempty(srcList.Inport{j})
                        subsysPortIsConnected=true;
                        break;
                    end
                end
                if subsysPortIsConnected
                    break;
                end
            end
        end

        if strcmp(get_param(oldBlockHandles{i},'BlockType'),'Outport')
            for j=1:length(ioBlks_list.Outport)
                for k=1:length(ioBlks_list.Outport{j})
                    blkName=ioBlks_list.Outport{j}{k};
                    if get_param(blkName,'Handle')==oldBlockHandles{i}&&~isempty(srcList)&&isfield(srcList,'Outport')&&~isempty(srcList.Outport{j})
                        subsysPortIsConnected=true;
                        break;
                    end
                end
                if subsysPortIsConnected
                    break;
                end
            end
        end

        if ismember(get_param(oldBlockHandles{i},'BlockType'),blockTypeList)||...
            (ismember(get_param(oldBlockHandles{i},'BlockType'),{'Inport','Outport'})&&subsysPortIsConnected)
            continue;
        end

        oldPortHandlesWithoutIO{end+1}=oldPortHandles{i};%#ok<*AGROW>
        blockName=get_param(oldBlockHandles{i},'Name');
        blockName=strrep(blockName,'/','');
        dstFullPath=[get_param(subSys,'Parent'),'/',blockName];
        newBlockHandle=add_block(oldBlockHandles{i},dstFullPath,'MakeNameUnique','on');
        newPortHandles{end+1}=get_param(newBlockHandle,'PortHandles');
        for j=1:length(oldPortHandlesWithoutIO{end}.Outport)
            lineHdl=get_param(oldPortHandlesWithoutIO{end}.Outport(j),'Line');
            if lineHdl==-1
                continue;
            end
            for k=1:length(signalProps)
                try %#ok<*TRYNC>
                    origSigObj=get_param(oldPortHandlesWithoutIO{end}.Outport(j),signalProps{k});
                    set_param(newPortHandles{end}.Outport(j),signalProps{k},origSigObj);
                end
            end
        end

        sP=get_param(subSys,'Position');
        pH=get_param(newBlockHandle,'Position');
        set_param(newBlockHandle,'Position',[pH(1)+sP(1),pH(2)+sP(2),pH(3)+sP(1),pH(4)+sP(2)]);
    end

    Simulink.SimplifyModel.removeUnconnectedLines(get_param(subSys,'Parent'));
    reconnectBlocksInsideSubsystem(subSys,newPortHandles,oldPortHandlesWithoutIO);
    reconnectBlocksOutsideSubsystem(subSys,prtList,newPortHandles,oldPortHandlesWithoutIO,srcList,portHandlesInParent);
    delete_block(subSys);


    function reconnectBlocksOutsideSubsystem(subSys,prtList,newPortHandles,oldPortHandles,srcList,portHandlesInParent)

        if isempty(prtList)||isempty(srcList)
            return;
        end
        portTypes=fields(prtList);

        for i=1:length(portTypes)
            portH=prtList.(portTypes{i});
            srcH=srcList.(portTypes{i});
            if strcmpi(portTypes{i},'Outport')||strcmpi(portTypes{i},'StatePort')
                for j=1:length(portH)
                    if~isempty(portH{j})
                        for k=1:length(srcH{j})
                            connectOneLine(subSys,portH{j}(1),newPortHandles,oldPortHandles,srcH{j}(k),portHandlesInParent,portHandlesInParent);
                        end
                    end
                end
            else
                for j=1:length(portH)
                    if~isempty(srcH{j})
                        for k=1:length(portH{j})
                            connectOneLine(subSys,srcH{j}(1),portHandlesInParent,portHandlesInParent,portH{j}(k),newPortHandles,oldPortHandles);
                        end
                    end
                end
            end
        end


        function reconnectBlocksInsideSubsystem(subSys,newPortHandles,oldPortHandles)

            lineHandles=find_system(subSys,'SearchDepth',1,'FindAll','on','type','line','SegmentType','trunk');
            for i=1:length(lineHandles)
                if strcmpi(get_param(lineHandles(i),'Connected'),'on')
                    dstPortHandle=get_param(lineHandles(i),'DstPortHandle');
                    srcPortHandle=get_param(lineHandles(i),'SrcPortHandle');
                    for j=1:length(dstPortHandle)
                        if srcPortHandle~=-1&&dstPortHandle(j)~=-1
                            connectOneLine(subSys,srcPortHandle,newPortHandles,oldPortHandles,dstPortHandle(j),newPortHandles,oldPortHandles);
                        end
                    end
                end
            end


            function connectOneLine(subSys,srcPortHandle,newSrcPortHandles,oldSrcPortHandles,dstPortHandle,newDstPortHandles,oldDstPortHandles)

                dstPortIndex=0;
                srcPortIndex=0;
                dstPortType='';
                srcPortType='';
                dstBlockIndex=[];
                srcBlockIndex=[];

                for k=1:length(oldDstPortHandles)
                    portTypes=fields(oldDstPortHandles{k});
                    for i=1:length(portTypes)
                        portH=oldDstPortHandles{k}.(portTypes{i});

                        if~dstPortIndex&&dstPortHandle~=-1
                            for j=1:length(portH)
                                if dstPortHandle==portH(j)
                                    dstPortIndex=j;
                                    dstPortType=portTypes{i};
                                    dstBlockIndex=k;
                                    break;
                                end
                            end
                        end
                    end
                end


                for k=1:length(oldSrcPortHandles)
                    portTypes=fields(oldSrcPortHandles{k});
                    for i=1:length(portTypes)
                        portH=oldSrcPortHandles{k}.(portTypes{i});

                        if~srcPortIndex&&srcPortHandle~=-1
                            for j=1:length(portH)
                                if srcPortHandle==portH(j)
                                    srcPortIndex=j;
                                    srcPortType=portTypes{i};
                                    srcBlockIndex=k;
                                    break;
                                end
                            end
                        end
                    end
                end


                if dstPortIndex&&srcPortIndex
                    lineHdl=get_param(oldSrcPortHandles{srcBlockIndex}.(srcPortType)(srcPortIndex),'Line');
                    newDestLine=get_param(newDstPortHandles{dstBlockIndex}.(dstPortType)(dstPortIndex),'Line');
                    if all(newDestLine==-1)
                        lineHdlNew=add_line(get_param(subSys,'Parent'),newSrcPortHandles{srcBlockIndex}.(srcPortType)(srcPortIndex),...
                        newDstPortHandles{dstBlockIndex}.(dstPortType)(dstPortIndex));
                    end
                    if lineHdl~=-1
                        try
                            set_param(lineHdlNew,'Name',get_param(lineHdl,'Name'));
                        end
                    end
                end


                function[blocksPortHandles,blocksHandles]=get_portHandles(subSys)
                    blocksPortHandles={};
                    blocksHandles={};

                    blocksNames=find_system(subSys,'SearchDepth',1,'LookUnderMasks','all','Type','Block');
                    for i=1:length(blocksNames)
                        parent=get_param(blocksNames{i},'Parent');
                        if get_param(parent,'Handle')==get_param(subSys,'Handle')
                            blocksHandles{end+1}=get_param(blocksNames{i},'Handle');
                            blocksPortHandles{end+1}=get_param(blocksNames{i},'PortHandles');
                        end
                    end



                    function datasource=getCommonDataSource(referredModel,mdlName)
                        refmdlWorkspace=get_param(referredModel,'modelworkspace');
                        mdlWorkspace=get_param(mdlName,'modelworkspace');

                        datasource='';
                        switch mdlWorkspace.DataSource
                        case 'MAT-File'
                            datasource=['load(''',mdlWorkspace.FileName,''');'];
                        case{'MATLAB Code','M-Code'}
                            datasource=mdlWorkspace.MATLABCode;
                        case 'MATLAB File'
                            [fpath,fname]=fileparts(mdlWorkspace.FileName);
                            datasource=['addpath(''',fpath,''');',10,'eval(''',fname,''');'];
                        case{'Model File','MDL-File'}
                        otherwise

                        end
                        switch refmdlWorkspace.DataSource
                        case 'MAT-File'
                            datasource=[datasource,10,'load(''',refmdlWorkspace.FileName,''');'];
                        case{'MATLAB Code','M-Code'}
                            datasource=[datasource,10,refmdlWorkspace.MATLABCode];
                        case 'MATLAB File'
                            [fpath,fname]=fileparts(refmdlWorkspace.FileName);
                            datasource=[datasource,10,'addpath(''',fpath,''');',10,'eval(''',fname,''');'];
                        case{'Model File','MDL-File'}
                        otherwise

                        end

                        mdlWorkspace.DataSource='MATLAB Code';
                        mdlWorkspace.MATLABCode=datasource;
                        mdlWorkspace.reload;
