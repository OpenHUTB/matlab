function crossBoundaryRec=gatherMdlRefBoundarySharedDT(h,blkObj,PathItem)







    crossBoundaryRec=[];


    if strcmpi(blkObj.ProtectedModel,'on')
        return;
    end

    refModel=blkObj.ModelName;
    portHandles=blkObj.PortHandles;

    if strncmp(PathItem,'inport',6)
        portTypeStr='Inport';
        portIndexStr=strrep(PathItem,'inport','');
        portNum=str2double(portIndexStr);
        mdlBlkInportSet=portNum;
        mdlBlkOutportSet=[];
    else
        portIndexStr=PathItem;
        portTypeStr='Outport';
        portNum=str2double(portIndexStr);
        mdlBlkInportSet=[];
        mdlBlkOutportSet=portNum;
    end

    portTypeHandles=portHandles.(portTypeStr);
    if~isempty(portTypeHandles)&&h.hIsNonVirtualBus(portTypeHandles(portNum))

        return;
    end

    portIndexStrToFind=portIndexStr;


    if blkObj.isSynthesized


        busuInfoString=['VirtualBus',portTypeStr,'Information'];
        vBusInfo=get_param(blkObj.Handle,busuInfoString);
        if(vBusInfo{portNum}.flatIndex>=0)





            return;
        end
        origPortNum=vBusInfo{portNum}.originalPort;
        portIndexStrToFind=int2str(origPortNum);
    end

    portInfo=getPortInfoFromOrigSubModel(refModel,portIndexStrToFind,portTypeStr);
    if isempty(portInfo)
        return;
    end

    crossBoundaryRec.portInfo=portInfo;

    sharedListPorts=h.hShareDTSpecifiedPorts(blkObj,mdlBlkInportSet,mdlBlkOutportSet);
    if~isempty(sharedListPorts)
        crossBoundaryRec.connectedBlkInfo=sharedListPorts{1};
    end


    function portInfo=getPortInfoFromOrigSubModel(refModel,portIndexStr,BlockType)

        portInfo=[];
        rootport=find_system(refModel,'SearchDepth',1,'BlockType',BlockType);
        if isempty(rootport)
            return;
        end


        port=find_system(rootport,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Port',portIndexStr);
        if isempty(port)
            return;
        end

        info.blkObj=get_param(port{1},'Object');
        info.pathItem='1';
        portInfo=info;





