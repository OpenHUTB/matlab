function connectPortToEventRouting(varargin)



    portPathList=varargin;
    if~isempty(portPathList)
        modelName=bdroot(portPathList{1});
        isExportFcnModel=autosar.validation.ExportFcnValidator.isExportFcn(modelName);
    end

    for portIdx=1:length(portPathList)
        portPath=portPathList{portIdx};

        isInport=strcmp(get_param(portPath,'BlockType'),'Inport');

        if isExportFcnModel&&...
            (isConnectedToFcnCallSubSystem(portPath)||...
            isConnectedToMsgTriggeredSubSystem(portPath))&&...
            ~isConnectedToLinkedSubsystem(portPath)




            connectedBlkH=getConnectedBlkH(portPath);


            sysPortData=get_param(connectedBlkH,'PortConnectivity');
            if isInport
                sysPortProp='SrcBlock';
            else
                sysPortProp='DstBlock';
            end
            rootPortHandle=get_param(portPath,'Handle');
            sysPort=[];
            for ii=1:length(sysPortData)
                if isempty(sysPortData(ii).(sysPortProp))


                    continue;
                end
                sysPortTargetPortH=sysPortData(ii).(sysPortProp);
                for jj=1:length(sysPortTargetPortH)
                    if sysPortTargetPortH(jj)==rootPortHandle
                        sysPort=sysPortData(ii);
                        break;
                    end
                end
                if~isempty(sysPort)
                    break;
                end
            end

            portNum=sysPort.Type;
            if isInport
                blockType='Inport';
            else
                blockType='Outport';
            end
            inSysPortPath=find_system([getfullname(connectedBlkH),'/'],...
            'LookUnderMasks','on','FollowLinks','on','SearchDepth',1,...
            'BlockType',blockType,...
            'Port',portNum);
            assert(length(inSysPortPath)==1,'Expected to find exactly one port');

            autosar.validation.fixits.connectPortToEventRouting(inSysPortPath{:});
        else



            if isConnectedToEventBlk(portPath)
                continue;
            end

            lineHandleData=get_param(portPath,'LineHandles');
            if isInport
                lineH=lineHandleData.Outport;
                lhsPortHandle=get_param(lineH,'SrcPortHandle');
                rhsPortHandles=get_param(lineH,'DstPortHandle');
                evtRoutingBlKPath='autosarlibaprouting/Event Receive';
                blockOrientation='west';
            else
                lineH=lineHandleData.Inport;
                lhsPortHandle=get_param(lineH,'SrcPortHandle');
                rhsPortHandles=get_param(lineH,'DstPortHandle');
                evtRoutingBlKPath='autosarlibaprouting/Event Send';
                blockOrientation='east';
            end


            delete_line(lineH);

            sysName=get_param(portPath,'Parent');
            evtRoutingBlkName=strsplit(evtRoutingBlKPath,'/');
            evtRoutingBlkName=evtRoutingBlkName{end};
            evtRoutingBlkH=add_block(evtRoutingBlKPath,[sysName,'/',evtRoutingBlkName],...
            'MakeNameUnique','on');

            evtRoutingBlkPortData=get_param(evtRoutingBlkH,'PortHandles');
            add_line(sysName,lhsPortHandle,evtRoutingBlkPortData.Inport);
            for ii=1:length(rhsPortHandles)
                add_line(sysName,evtRoutingBlkPortData.Outport,rhsPortHandles(ii));
            end


            autosar.mm.mm2sl.MRLayoutManager.homeBlk(evtRoutingBlkH,...
            'BlockOrientation',blockOrientation);
            autosar.mm.mm2sl.MRLayoutManager.homeBlk(portPath,'Gap',60);

        end
    end
end

function isConnected=isConnectedToFcnCallSubSystem(portPath)

    isConnected=false;

    connectedBlockH=getConnectedBlkH(portPath);

    isConnectedToSubsys=strcmp(get_param(connectedBlockH,'BlockType'),'SubSystem');

    if~isConnectedToSubsys

        return;
    end


    isConnected=~isempty(autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(connectedBlockH,...
    'TriggerPort','','TriggerType','function-call'));
end

function isConnected=isConnectedToMsgTriggeredSubSystem(portPath)

    isConnected=false;

    connectedBlockH=getConnectedBlkH(portPath);

    isConnectedToSubsys=strcmp(get_param(connectedBlockH,'BlockType'),'SubSystem');

    if~isConnectedToSubsys

        return;
    end


    isConnected=~isempty(autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(connectedBlockH,...
    'TriggerPort','','TriggerType','message'));
end

function isConnected=isConnectedToLinkedSubsystem(portPath)

    connectedBlockH=getConnectedBlkH(portPath);

    isConnected=~isempty(libinfo(connectedBlockH,'SearchDepth',0));
end

function connectedBlockH=getConnectedBlkH(portPath)

    portData=get_param(portPath,'PortConnectivity');

    isInport=strcmp(get_param(portPath,'BlockType'),'Inport');

    if isInport
        connectedBlockH=portData.DstBlock;
    else
        connectedBlockH=portData.SrcBlock;
    end
end

function isConnected=isConnectedToEventBlk(portPath)



    connectedBlockH=getConnectedBlkH(portPath);


    isInport=strcmp(get_param(portPath,'BlockType'),'Inport');

    if isInport
        isConnected=autosar.blocks.adaptiveplatform.EventBlock.isEventReceiveBlock(...
        connectedBlockH);
    else
        isConnected=autosar.blocks.adaptiveplatform.EventBlock.isEventSendBlock(...
        connectedBlockH);
    end
end



