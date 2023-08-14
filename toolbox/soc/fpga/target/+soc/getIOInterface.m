function intfInfo=getIOInterface(sys,duts,topInfo)
    intfInfo=containers.Map;
    topIntfInfo=topInfo.intfInfo;
    for ii=1:numel(duts)
        thisBlk=[sys,'/',duts{ii}];

        inPorts=find_system(thisBlk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport');
        outPorts=find_system(thisBlk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport');
        allPorts=[inPorts;outPorts];
        prevRate=0;
        for i=1:numel(allPorts)
            thisRate=get_param(allPorts{i},'CompiledSampleTime');
            if~eq(thisRate(1),prevRate)&&(i>1)
                error(message('soc:msgs:requireSameSampleRateForAllPorts',allPorts{i}));
            end
            prevRate=thisRate(1);
        end


        A4sSlaveIndex=0;
        A4sMasterIndex=0;
        mapA4sSlave=containers.Map;
        mapA4sMaster=containers.Map;

        A4svSlaveIndex=0;
        A4svMasterIndex=0;
        mapA4svSlave=containers.Map;
        mapA4svMaster=containers.Map;

        A4mIndex=0;
        mapA4m=containers.Map;

        for i=1:numel(allPorts)
            thisPort=allPorts{i};
            [cntdBlks,cntdPorts,~,~]=soc.util.getConnectedBlk(thisPort);
            if~iscell(cntdBlks)
                cntdBlk=cntdBlks;
                cntdPort=cntdPorts;
            elseif numel(cntdBlks)==1
                cntdBlk=cntdBlks{1};
                cntdPort=cntdPorts{1};
            else
                error(message('soc:msgs:dutPortConnectMultipleBlks',thisPort));
            end
            if~isempty(cntdBlk)
                cntdBlkRef=soc.util.getRefBlk(cntdBlk);
                cntdBlkPath=cntdBlk;
                [isCstmIP,internalCstmIPBlk]=soc.internal.isSoCBCustomIPBlk(cntdBlk);
                if strcmpi(cntdBlkRef,'hwlogicconnlib/Stream Connector')||...
                    ((strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Selector')||...
                    strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Creator'))&&...
                    any(strcmpi(get_param(cntdBlkPath,'Protocol'),'Data stream')))||...
                    isA4sPort(cntdBlk,topIntfInfo)
                    if strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Creator')
                        hp=get_param(cntdBlk,'PortHandles');
                        hop=hp.Outport;
                        hline=get_param(hop(1),'Line');
                        cntdBlks=soc.util.getDstBlk(hline);
                        cntdBlk=cntdBlks{1};
                    elseif strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Selector')
                        hp=get_param(cntdBlk,'PortHandles');
                        hinp=hp.Inport;
                        hline=get_param(hinp(1),'Line');
                        cntdBlk=soc.util.getSrcBlk(hline);
                    end

                    if isA4sPort(cntdBlk,topIntfInfo)
                        thisTopIntfInfo=topIntfInfo(cntdBlk);
                        cntdPortOriginal=cntdPort;
                        cntdPort=thisTopIntfInfo.interfacePort;
                        cntdBlk=thisTopIntfInfo.interface;
                        if strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Selector')&&...
                            strcmpi(get_param(cntdBlkPath,'Protocol'),'Data stream')&&...
                            strcmpi(get_param(cntdBlkPath,'ctrltype'),'Ready')
                            cntdPort='wrready';
                        elseif strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Creator')&&...
                            strcmpi(get_param(cntdBlkPath,'Protocol'),'Data stream')&&...
                            strcmpi(get_param(cntdBlkPath,'ctrltype'),'Valid')
                            if strcmpi(cntdPortOriginal,'valid')
                                cntdPort='wrvalid';
                            elseif strcmpi(cntdPortOriginal,'tlast')
                                cntdPort='wrlast';
                            end
                        elseif strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Selector')&&...
                            strcmpi(get_param(cntdBlkPath,'Protocol'),'Data stream')&&...
                            strcmpi(get_param(cntdBlkPath,'ctrltype'),'Valid')
                            if strcmpi(cntdPortOriginal,'valid')
                                cntdPort='rdvalid';
                            elseif strcmpi(cntdPortOriginal,'tlast')
                                cntdPort='rdlast';
                            end
                        elseif strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Creator')&&...
                            strcmpi(get_param(cntdBlkPath,'Protocol'),'Data stream')&&...
                            strcmpi(get_param(cntdBlkPath,'ctrltype'),'Ready')
                            cntdPort='rdready';
                        end
                    end
                    if(isRdy(cntdPort)&&isInPort(thisPort))||...
                        (~isRdy(cntdPort)&&~isInPort(thisPort))
                        if~isKey(mapA4sMaster,cntdBlk)
                            mapA4sMaster(cntdBlk)=A4sMasterIndex;
                            A4sMasterIndex=A4sMasterIndex+1;
                        end
                        thisIntfName=getIOInterfaceAXI('axis_m',mapA4sMaster(cntdBlk));
                        thisIntfPort=getIOMappingAXIS(cntdPort,thisPort);
                        intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisIntfPort);
                    else
                        if~isKey(mapA4sSlave,cntdBlk)
                            mapA4sSlave(cntdBlk)=A4sSlaveIndex;
                            A4sSlaveIndex=A4sSlaveIndex+1;
                        end
                        thisIntfName=getIOInterfaceAXI('axis_s',mapA4sSlave(cntdBlk));
                        thisIntfPort=getIOMappingAXIS(cntdPort,thisPort);
                        intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisIntfPort);
                    end
                elseif strcmpi(cntdBlkRef,'hwlogicconnlib/Video Stream Connector')||...
                    ((strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Selector')||...
                    strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Creator'))&&...
                    any(strcmpi(get_param(cntdBlkPath,'Protocol'),'Pixel stream')))||...
                    isA4svPort(cntdBlk,topIntfInfo)
                    if strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Creator')
                        hp=get_param(cntdBlk,'PortHandles');
                        hop=hp.Outport;
                        hline=get_param(hop(1),'Line');
                        cntdBlks=soc.util.getDstBlk(hline);
                        cntdBlk=cntdBlks{1};
                    elseif strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Selector')
                        hp=get_param(cntdBlk,'PortHandles');
                        hinp=hp.Inport;
                        hline=get_param(hinp(1),'Line');
                        cntdBlk=soc.util.getSrcBlk(hline);
                    end
                    if isA4svPort(cntdBlk,topIntfInfo)
                        thisTopIntfInfo=topIntfInfo(cntdBlk);
                        cntdPortOriginal=cntdPort;
                        cntdPort=thisTopIntfInfo.interfacePort;
                        cntdBlk=thisTopIntfInfo.interface;
                        if strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Selector')&&...
                            strcmpi(get_param(cntdBlkPath,'Protocol'),'Pixel stream')&&...
                            strcmpi(get_param(cntdBlkPath,'ctrltype'),'Ready')
                            cntdPort='wrready';
                        elseif strcmpi(cntdBlkRef,'hwlogicconnlib/SoC Bus Creator')&&...
                            strcmpi(get_param(cntdBlkPath,'Protocol'),'Pixel stream')
                            if strcmpi(cntdPortOriginal,'ready')
                                cntdPort='rdready';
                            elseif strcmpi(cntdPortOriginal,'fsync')
                                cntdPort='framesync';
                            end
                        end
                    end
                    if strcmpi(cntdPort,'framesync')
                        intfInfo(thisPort)=struct('interface','External Port','interfacePort','');
                    elseif(isRdy(cntdPort)&&isInPort(thisPort))||...
                        (~isRdy(cntdPort)&&~isInPort(thisPort))
                        if~isKey(mapA4svMaster,cntdBlk)
                            mapA4svMaster(cntdBlk)=A4svMasterIndex;
                            A4svMasterIndex=A4svMasterIndex+1;
                        end
                        thisIntfName=getIOInterfaceAXI('axisv_m',mapA4svMaster(cntdBlk));
                        thisIntfPort=getIOMappingAXISV(cntdPort);
                        intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisIntfPort);
                    else
                        if~isKey(mapA4svSlave,cntdBlk)
                            mapA4svSlave(cntdBlk)=A4svSlaveIndex;
                            A4svSlaveIndex=A4svSlaveIndex+1;
                        end
                        thisIntfName=getIOInterfaceAXI('axisv_s',mapA4svSlave(cntdBlk));
                        thisIntfPort=getIOMappingAXISV(cntdPort);
                        intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisIntfPort);
                    end
                elseif isA4mPort(cntdBlk,topIntfInfo)
                    thisTopIntfInfo=topIntfInfo(cntdBlk);
                    ioIntfStr=thisTopIntfInfo.interface;
                    cntdPort=thisTopIntfInfo.interfacePort;
                    dataWidth=thisTopIntfInfo.dataWidth;
                    memType=thisTopIntfInfo.memType;
                    aximType=ioIntfStr(1:7);
                    cntdBlk=ioIntfStr(9:end);
                    if~isKey(mapA4m,cntdBlk)
                        mapA4m(cntdBlk)=A4mIndex;
                        A4mIndex=A4mIndex+1;
                    end
                    thisIntfName=getIOInterfaceAXI(aximType,mapA4m(cntdBlk));
                    thisIntfPort=getIOMappingAXI4(cntdPort);
                    intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisIntfPort,'dataWidth',dataWidth,'memType',memType);

                elseif isA4litePort(cntdBlk,topIntfInfo)
                    thisTopIntfInfo=topIntfInfo(cntdBlk);
                    thisIntfName=getIOInterfaceAXI('axi4_lite',0);
                    intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisTopIntfInfo.regOffset);
                elseif isAxi4Port(cntdBlk,topIntfInfo)
                    thisTopIntfInfo=topIntfInfo(cntdBlk);
                    thisIntfName=getIOInterfaceAXI('axi4',0);
                    intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisTopIntfInfo.regOffset);
                elseif isInterruptPort(cntdBlk,topIntfInfo)
                    intrChPortNum=topIntfInfo(cntdBlk).intrChPortNum;
                    triggerType=topIntfInfo(cntdBlk).triggerType;
                    intfInfo(thisPort)=struct('interface','External Port','interfacePort','interrupt','intrChPortNum',intrChPortNum,'triggerType',triggerType);
                elseif isCstmIP
                    portIntfInfo=soc.blkcb.customIPCb('getPortIntfInfo',internalCstmIPBlk,cntdPort);

                    if strcmpi(portIntfInfo.Type,'I/O')
                        intfInfo(thisPort)=struct('interface','External Port','interfacePort','');

                    elseif strcmpi(portIntfInfo.Type,'AXI4 Stream')

                        if(isRdy(portIntfInfo.SignalID)&&isInPort(thisPort))||...
                            (~isRdy(portIntfInfo.SignalID)&&~isInPort(thisPort))
                            if~isKey(mapA4sMaster,cntdBlk)
                                mapA4sMaster(cntdBlk)=A4sMasterIndex;
                                A4sMasterIndex=A4sMasterIndex+1;
                            end
                            thisIntfName=getIOInterfaceAXI('axis_m',mapA4sMaster(cntdBlk));
                            thisIntfPort=getIOMappingAXIS(portIntfInfo.SignalID,thisPort);
                            intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisIntfPort);
                        else
                            if~isKey(mapA4sSlave,cntdBlk)
                                mapA4sSlave(cntdBlk)=A4sSlaveIndex;
                                A4sSlaveIndex=A4sSlaveIndex+1;
                            end
                            thisIntfName=getIOInterfaceAXI('axis_s',mapA4sSlave(cntdBlk));
                            thisIntfPort=getIOMappingAXIS(portIntfInfo.SignalID,thisPort);
                            intfInfo(thisPort)=struct('interface',thisIntfName,'interfacePort',thisIntfPort);
                        end

                    end

                else
                    intfInfo(thisPort)=struct('interface','External Port','interfacePort','');
                end
            else
                intfInfo(thisPort)=struct('interface','External Port','interfacePort','');
            end
        end
    end

    topIntfAllKeys=keys(topIntfInfo);
    topIntfAllValues=values(topIntfInfo);
    intfAllKeys=[topIntfAllKeys,keys(intfInfo)];
    intfAllValues=[topIntfAllValues,values(intfInfo)];
    if~isempty(intfAllKeys)
        intfInfo=containers.Map(intfAllKeys,intfAllValues);
    end
end

function intfName=getIOInterfaceAXI(type,id)
    switch lower(type)
    case 'axis_m'
        IOInterfaceStr=['AXI4-Stream ',num2str(id),' Master'];
    case 'axis_s'
        IOInterfaceStr=['AXI4-Stream ',num2str(id),' Slave'];
    case 'axisv_m'
        IOInterfaceStr=['AXI4-Stream Video ',num2str(id),' Master'];
    case 'axisv_s'
        IOInterfaceStr=['AXI4-Stream Video ',num2str(id),' Slave'];
    case 'axim_wr'
        IOInterfaceStr=['AXI4 Master ',num2str(id),' Write'];
    case 'axim_rd'
        IOInterfaceStr=['AXI4 Master ',num2str(id),' Read'];
    case 'axi4_lite'
        IOInterfaceStr='AXI4-Lite';
    case 'axi4'
        IOInterfaceStr='AXI4';
    end
    intfName=IOInterfaceStr;
end

function intfPort=getIOMappingAXISV(cntdPort)
    switch lower(cntdPort)
    case{'wrdata','rddata'}
        IOInterfaceMappingStr='Pixel Data';
    case{'wrctrlin','rdctrlout'}
        IOInterfaceMappingStr='Pixel Control Bus';
    case{'wrctrlout','rdctrlin','wrready','rdready'}
        IOInterfaceMappingStr='Ready';
    otherwise
        error(message('soc:msgs:AXISVideoIOMappingError'));
    end
    intfPort=IOInterfaceMappingStr;
end

function intfPort=getIOMappingAXIS(cntdPort,thisPort)
    switch lower(cntdPort)
    case{'wrdata','rddata'}
        IOInterfaceMappingStr='Data';
    case{'wrvalid','rdvalid','valid'}
        IOInterfaceMappingStr='Valid';
    case{'wrready','rdready','ready'}
        IOInterfaceMappingStr='Ready';
    case{'wrlast','rdlast'}
        IOInterfaceMappingStr='TLAST';
    otherwise
        error(message('soc:msgs:IlleagalUseOfBusBlksInStream',thisPort));
    end
    intfPort=IOInterfaceMappingStr;
end

function intfPort=getIOMappingAXI4(cntdPort)
    switch lower(cntdPort)
    case 'rdctrlout'
        IOInterfaceMappingStr='Read Slave to Master Bus';
    case 'rdctrlin'
        IOInterfaceMappingStr='Read Master to Slave Bus';
    case 'wrctrlout'
        IOInterfaceMappingStr='Write Slave to Master Bus';
    case 'wrctrlin'
        IOInterfaceMappingStr='Write Master to Slave Bus';
    case{'rddata','wrdata'}
        IOInterfaceMappingStr='Data';
    otherwise
        error(message('soc:msgs:AXI4IOMappingError'));
    end
    intfPort=IOInterfaceMappingStr;

end

function result=isInPort(thisPort)
    result=strcmpi(get_param(thisPort,'BlockType'),'inport');
end

function result=isRdy(portName)
    result=contains(portName,'ready','IgnoreCase',true)||...
    contains(portName,'rdy','IgnoreCase',true)||...
    strcmpi(portName,'wrctrlout')||...
    strcmpi(portName,'rdctrlin');
end

function result=isA4sPort(blk,topIntfInfo)
    result=false;

    if(strcmpi(get_param(blk,'BlockType'),'inport')||strcmpi(get_param(blk,'BlockType'),'outport'))&&isKey(topIntfInfo,blk)
        thisIntfInfo=topIntfInfo(blk);
        if startsWith(lower(thisIntfInfo.interface),'axis')||startsWith(lower(thisIntfInfo.interface),'dma')
            result=true;
        end
    end
end

function result=isA4mPort(blk,topIntfInfo)
    result=false;
    if(strcmpi(get_param(blk,'BlockType'),'inport')||strcmpi(get_param(blk,'BlockType'),'outport'))&&isKey(topIntfInfo,blk)
        thisIntfInfo=topIntfInfo(blk);
        if contains(lower(thisIntfInfo.interface),'axim')
            result=true;
        end
    end
end

function result=isA4svPort(blk,topIntfInfo)
    result=false;
    if(strcmpi(get_param(blk,'BlockType'),'inport')||strcmpi(get_param(blk,'BlockType'),'outport'))&&isKey(topIntfInfo,blk)
        thisIntfInfo=topIntfInfo(blk);
        if contains(lower(thisIntfInfo.interface),'axi_vdma')
            result=true;
        end
    end
end

function result=isA4litePort(blk,topIntfInfo)
    result=false;
    if(strcmpi(get_param(blk,'BlockType'),'inport')||strcmpi(get_param(blk,'BlockType'),'outport'))&&isKey(topIntfInfo,blk)
        thisIntfInfo=topIntfInfo(blk);
        if contains(lower(thisIntfInfo.interface),'axi4_lite')
            result=true;
        end
    end
end

function result=isAxi4Port(blk,topIntfInfo)
    result=false;
    if(strcmpi(get_param(blk,'BlockType'),'inport')||strcmpi(get_param(blk,'BlockType'),'outport'))&&isKey(topIntfInfo,blk)
        thisIntfInfo=topIntfInfo(blk);
        if contains(lower(thisIntfInfo.interface),'axi4')
            result=true;
        end
    end
end

function result=isInterruptPort(blk,topIntfInfo)
    result=false;
    if(strcmpi(get_param(blk,'BlockType'),'outport'))&&isKey(topIntfInfo,blk)
        thisIntfInfo=topIntfInfo(blk);
        if contains(lower(thisIntfInfo.interface),'interrupt')
            result=true;
        end
    end
end
