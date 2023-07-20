function validateVectorPortFrameMode(obj,hIOPort,hTableMap,interfaceStr)




    if~obj.isFrameMode
        return;
    end


    hTurnkey=hTableMap.hTable.hTurnkey;
    if hTurnkey.hTable.isMLHDLC
        error(message('hdlcommon:workflow:VectorPortUnsupported',interfaceStr,hIOPort.PortName));
    end


    if~hTurnkey.hStream.isAXI4StreamFrameMode
        return;
    end


    hasScalarMode=false;
    scalarInterfaceStr='';
    scalarPortName='';
    hStreamCell=hTurnkey.hStream.getAssignedAXI4StreamInterface;
    for ii=1:length(hStreamCell)
        hInterface=hStreamCell{ii};
        hChannelList=hInterface.hChannelList;
        channelIDlist=hChannelList.getChanneIDList;
        for jj=1:length(channelIDlist)
            channelID=channelIDlist{jj};
            hChannel=hChannelList.getChannel(channelID);
            [isChannelSubPortAssigned,hPort]=hChannel.isAnySubPortAssigned;
            if isChannelSubPortAssigned&&~hChannel.isFrameMode(hInterface)
                hasScalarMode=true;
                scalarInterfaceStr=hChannel.ChannelID;
                scalarPortName=hPort.getAssignedPortName;
                break;
            end
        end
        if hasScalarMode
            break;
        end
    end
    if hasScalarMode
        error(message('hdlcommon:interface:AXIStreamScalarError',scalarInterfaceStr,scalarPortName));
    end


    vectorModeCount=0;
    hStreamCell=hTurnkey.hStream.getAssignedAXI4StreamInterface;
    for ii=1:length(hStreamCell)
        hInterface=hStreamCell{ii};
        if hInterface.isFrameMode
            vectorModeCount=vectorModeCount+1;
        end

        if vectorModeCount>1
            error(message('hdlcommon:interface:AXIStreamVectorError'));
        end
    end

    vectorModeCount=0;
    for ii=1:length(hTableMap.hTable.hIOPortList.InputPortNameList)
        portName=hTableMap.hTable.hIOPortList.InputPortNameList{ii};
        hInterface=hTableMap.getInterface(portName);
        if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface
            if obj.isFrameMode
                vectorModeCount=vectorModeCount+1;
            end

            if vectorModeCount>1
                hChannel=obj.hChannelList.getChannelFromPortName(portName);
                assignedPortName=hChannel.getDataPort.getAssignedPortName;
                error(message('hdlcommon:interface:SubPortVectorPortExist',...
                hChannel.ChannelID,assignedPortName,hChannel.ChannelID));
            end
        end
    end

    vectorModeCount=0;
    for ii=1:length(hTableMap.hTable.hIOPortList.OutputPortNameList)
        portName=hTableMap.hTable.hIOPortList.OutputPortNameList{ii};
        hInterface=hTableMap.getInterface(portName);




        if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface
            if obj.isFrameMode
                vectorModeCount=vectorModeCount+1;
            end

            if vectorModeCount>1
                hChannel=obj.hChannelList.getChannelFromPortName(portName);
                assignedPortName=hChannel.getDataPort.getAssignedPortName;
                error(message('hdlcommon:interface:SubPortVectorPortExist',...
                hChannel.ChannelID,assignedPortName,hChannel.ChannelID));
            end
        end
    end


    p=hTurnkey.getPirInstance;
    topNetwork=p.getTopNetwork;




    streamInPortName='';
    serailizerInputRate=0;
    serailizerOutputRate=0;
    deserailizerInputRate=0;
    deserailizerOutputRate=0;

    for ii=1:length(hTableMap.hTable.hIOPortList.InputPortNameList)
        portName=hTableMap.hTable.hIOPortList.InputPortNameList{ii};
        hInterface=hTableMap.getInterface(portName);

        if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            portIndex=hIOPort.PortIndex;
            interfaceStr=hTableMap.getInterfaceStr(portName);
            streamInPortName=portName;




            portReceivers=topNetwork.PirInputSignals(portIndex+1).getReceivers;
            if length(portReceivers)~=1
                error(message('hdlcommon:interface:VectorModeSerializerNoConnect',interfaceStr,hIOPort.PortName));
            end
            SerializerComp=portReceivers.Component;
            if~isa(SerializerComp,'hdlcoder.block_comp')||...
                ~strcmpi(SerializerComp.BlockTag,'hdlsllib/HDL Operations/Serializer1D')
                error(message('hdlcommon:interface:VectorModeSerializerNoConnect',interfaceStr,hIOPort.PortName));
            end


            if~(length(SerializerComp.PirInputPorts)==1&&...
                length(SerializerComp.PirOutputPorts)==2&&...
                strcmpi(get_param(SerializerComp.SimulinkHandle,'ValidOut'),'on')&&...
                strcmpi(get_param(SerializerComp.SimulinkHandle,'StartOut'),'off'))
                error(message('hdlcommon:interface:VectorModeSerializerInvalid',interfaceStr,SerializerComp.Name,hIOPort.PortName));
            end


            if SerializerComp.PirOutputPorts(1).Signal.Type.getDimensions~=1
                error(message('hdlcoder:hdlstreaming:ConnectedSerializerOutScalar',interfaceStr,hIOPort.PortName,SerializerComp.Name));
            end


            portReceivers=topNetwork.PirInputSignals(portIndex+1).getReceivers;
            serializerComp=portReceivers.Component;
            serailizerInputRate=hIOPort.PortRate;
            serailizerOutputRate=serializerComp.PirOutputSignals(1).SimulinkRate;
        end
    end

    for ii=1:length(hTableMap.hTable.hIOPortList.OutputPortNameList)
        portName=hTableMap.hTable.hIOPortList.OutputPortNameList{ii};
        hInterface=hTableMap.getInterface(portName);

        if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface
            hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
            portIndex=hIOPort.PortIndex;
            interfaceStr=hTableMap.getInterfaceStr(portName);





            portDrivers=topNetwork.PirOutputSignals(portIndex+1).getDrivers;
            portReceivers=topNetwork.PirOutputSignals(portIndex+1).getReceivers;
            if length(portReceivers)~=1
                error(message('hdlcommon:interface:VectorModeDeserializerNoConnect',interfaceStr,hIOPort.PortName));
            end
            DeserializerComp=portDrivers.Component;
            if~isa(DeserializerComp,'hdlcoder.block_comp')||...
                ~strcmpi(DeserializerComp.BlockTag,'hdlsllib/HDL Operations/Deserializer1D')
                error(message('hdlcommon:interface:VectorModeDeserializerNoConnect',interfaceStr,hIOPort.PortName));
            end


            if~(length(DeserializerComp.PirOutputPorts)==1&&...
                length(DeserializerComp.PirInputPorts)==2&&...
                strcmpi(get_param(DeserializerComp.SimulinkHandle,'ValidIn'),'on')&&...
                strcmpi(get_param(DeserializerComp.SimulinkHandle,'StartIn'),'off'))
                error(message('hdlcommon:interface:VectorModeDeserializerInvalid',interfaceStr,DeserializerComp.Name,hIOPort.PortName));
            end


            if DeserializerComp.PirInputPorts(1).Signal.Type.getDimensions~=1
                error(message('hdlcoder:hdlstreaming:ConnectedDeserializerInScalar',interfaceStr,hIOPort.PortName,DeserializerComp.Name));
            end


            portDrivers=topNetwork.PirOutputSignals(portIndex+1).getDrivers;
            deserializerComp=portDrivers.Component;
            deserailizerInputRate=deserializerComp.PirInputSignals(1).SimulinkRate;
            deserailizerOutputRate=hIOPort.PortRate;
        end
    end

    if serailizerInputRate~=deserailizerOutputRate
        error(message('hdlcoder:hdlstreaming:AXIStreamSameRateError',streamInPortName));
    end

    if serailizerOutputRate~=deserailizerInputRate
        error(message('hdlcoder:hdlstreaming:AXIStreamSameBaseRateError',streamInPortName));
    end




    for ii=1:length(hTableMap.hTable.hIOPortList.InputPortNameList)
        portName=hTableMap.hTable.hIOPortList.InputPortNameList{ii};
        hInterface=hTableMap.getInterface(portName);

        hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
        portIndex=hIOPort.PortIndex;
        portRate=hIOPort.PortRate;
        interfaceStr=hTableMap.getInterfaceStr(portName);

        if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface
            continue;
        end

        if hInterface.isAddrBasedInterface


            portReceivers=topNetwork.PirInputSignals(portIndex+1).getReceivers;
            if length(portReceivers)~=1
                error(message('hdlcommon:interface:VectorModeRateTransitionNoConnect',...
                interfaceStr,hIOPort.PortName,hIOPort.PortName));
            end

            RTComp=portReceivers.Component;
            if~isa(RTComp,'hdlcoder.block_comp')||...
                ~strcmpi(RTComp.BlockTag,'built-in/RateTransition')
                error(message('hdlcommon:interface:VectorModeRateTransitionNoConnect',...
                interfaceStr,hIOPort.PortName,hIOPort.PortName));
            end


            if portRate~=serailizerInputRate
                error(message('hdlcoder:hdlstreaming:AllInPortsSameRateError',...
                hIOPort.PortName));
            end



            rtOutputRate=RTComp.PirOutputSignals(1).SimulinkRate;
            if rtOutputRate~=serailizerOutputRate
                error(message('hdlcoder:hdlstreaming:AXILiteInSameRateError',...
                hIOPort.PortName,RTComp.Name));
            end

        else


            if portRate~=serailizerOutputRate
                error(message('hdlcoder:hdlstreaming:AllExternalPortsSameRateError',...
                hIOPort.PortName));
            end
        end
    end

    for ii=1:length(hTableMap.hTable.hIOPortList.OutputPortNameList)
        portName=hTableMap.hTable.hIOPortList.OutputPortNameList{ii};
        hInterface=hTableMap.getInterface(portName);

        hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
        portIndex=hIOPort.PortIndex;
        portRate=hIOPort.PortRate;
        interfaceStr=hTableMap.getInterfaceStr(portName);

        if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface
            continue;
        end

        if hInterface.isAddrBasedInterface


            portDrivers=topNetwork.PirOutputSignals(portIndex+1).getDrivers;
            portReceivers=topNetwork.PirOutputSignals(portIndex+1).getReceivers;
            if length(portReceivers)~=1
                error(message('hdlcommon:interface:VectorModeRateTransitionNoConnect',...
                interfaceStr,hIOPort.PortName,hIOPort.PortName));
            end

            RTComp=portDrivers.Component;
            if~isa(RTComp,'hdlcoder.block_comp')||...
                ~strcmpi(RTComp.BlockTag,'built-in/RateTransition')
                error(message('hdlcommon:interface:VectorModeRateTransitionNoConnect',...
                interfaceStr,hIOPort.PortName,hIOPort.PortName));
            end


            if portRate~=deserailizerOutputRate
                error(message('hdlcoder:hdlstreaming:AllOutPortsSameRateError',...
                hIOPort.PortName));
            end


            rtInputRate=RTComp.PirInputSignals(1).SimulinkRate;
            if rtInputRate~=deserailizerInputRate
                error(message('hdlcoder:hdlstreaming:AXILiteOutSameRateError',...
                hIOPort.PortName,RTComp.Name));
            end

        else


            if portRate~=deserailizerInputRate
                error(message('hdlcoder:hdlstreaming:AllExternalPortsSameRateError',...
                hIOPort.PortName));
            end
        end
    end
end

