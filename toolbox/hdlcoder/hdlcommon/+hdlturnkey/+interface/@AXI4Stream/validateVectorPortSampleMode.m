function validateVectorPortSampleMode(obj,hIOPort,hTableMap,interfaceStr)


    if~hIOPort.isVector
        return;
    end


    hTurnkey=hTableMap.hTable.hTurnkey;
    if hTurnkey.hTable.isMLHDLC
        error(message('hdlcommon:workflow:VectorPortUnsupported',interfaceStr,hIOPort.PortName));
    end

    hChannel=obj.hChannelList.getChannelFromPortName(hIOPort.PortName);


    InterfaceOptions=hTableMap.getInterfaceOption(hIOPort.PortName);
    if~isempty(InterfaceOptions)
        PackingModeIndex=find(strcmp(InterfaceOptions,'PackingMode'));
        PackingMode=InterfaceOptions{PackingModeIndex+1};
    else
        PackingMode='';
    end



    PackedDataWidth=hdlshared.internal.VectorStreamUtils.getPackedDataWidth(hIOPort.WordLength,hIOPort.Dimension,hIOPort.isComplex,PackingMode);
    hSubPort=hChannel.getDataPort;

    if obj.IsGenericIP


        if PackedDataWidth>4096
            error(message('hdlcommon:workflow:VectorPortBitWidthLargerThan4096Bits',...
            interfaceStr,PackedDataWidth,hIOPort.PortName));
        end
    else

        if hChannel.isDataPort(hSubPort)&&...
            hChannel.RDOverrideDataBitwidth>0
            [~,~,requiredPortWidth]=hChannel.getPortWidth(hSubPort);
            if PackedDataWidth>requiredPortWidth
                error(message('hdlcommon:interface:SubPortNotFitRDOverride',...
                hChannel.ChannelID,requiredPortWidth,hIOPort.PortName,PackedDataWidth));
            end
        end
    end

    if hIOPort.PortType==hdlturnkey.IOType.IN




        if obj.isMaxDataWidthDefined&&PackedDataWidth>obj.SlaveChannelMaxDataWidth
            error(message('hdlcommon:workflow:VectorPortBitWidthLargerThanMaxDataWidth',interfaceStr,...
            hIOPort.PortName,PackedDataWidth,obj.SlaveChannelMaxDataWidth));
        end

    elseif hIOPort.PortType==hdlturnkey.IOType.OUT




        if obj.isMaxDataWidthDefined&&PackedDataWidth>obj.MasterChannelMaxDataWidth
            error(message('hdlcommon:workflow:VectorPortBitWidthLargerThanMaxDataWidth',interfaceStr,...
            hIOPort.PortName,PackedDataWidth,obj.MasterChannelMaxDataWidth));
        end

    else
        error(message('hdlcommon:workflow:InvalidInterfaceType',hIOPort.PortType));
    end


    InterfaceOptionsInp='';
    InterfaceOptionsOutp='';
    for ii=1:length(hTableMap.hTable.hIOPortList.InputPortNameList)
        portName=hTableMap.hTable.hIOPortList.InputPortNameList{ii};
        hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
        if hIOPort.isVector
            InterfaceOptionsInp=hTableMap.getInterfaceOption(hIOPort.PortName);
            if~isempty(InterfaceOptionsInp)
                PackingModeIndex=find(strcmp(InterfaceOptionsInp,'PackingMode'));
                PackingModeInp=InterfaceOptionsInp{PackingModeIndex+1};
                SamplePackingDimensionIndex=find(strcmp(InterfaceOptionsInp,'SamplePackingDimension'));
                SamplePackingDimensionInp=InterfaceOptionsInp{SamplePackingDimensionIndex+1};
                InputinterfaceStr=hTableMap.getInterfaceStr(portName);
                InputportName=portName;
            end
        end
    end

    for ii=1:length(hTableMap.hTable.hIOPortList.OutputPortNameList)
        portName=hTableMap.hTable.hIOPortList.OutputPortNameList{ii};
        hIOPort=hTableMap.hTable.hIOPortList.getIOPort(portName);
        if hIOPort.isVector
            InterfaceOptionsOutp=hTableMap.getInterfaceOption(hIOPort.PortName);
            if~isempty(InterfaceOptionsOutp)
                PackingModeIndex=find(strcmp(InterfaceOptionsOutp,'PackingMode'));
                PackingModeOutp=InterfaceOptionsOutp{PackingModeIndex+1};
                SamplePackingDimensionIndex=find(strcmp(InterfaceOptionsOutp,'SamplePackingDimension'));
                SamplePackingDimensionOutp=InterfaceOptionsOutp{SamplePackingDimensionIndex+1};
                OutputinterfaceStr=hTableMap.getInterfaceStr(portName);
                OutputportName=portName;
            end
        end
    end
    NoofAssignedChannels=obj.getAssignedChannelIDList;
    if length(NoofAssignedChannels)>1&&~isempty(InterfaceOptionsOutp)&&~isempty(InterfaceOptionsInp)
        if~strcmp(SamplePackingDimensionInp,SamplePackingDimensionOutp)||~strcmp(PackingModeInp,PackingModeOutp)
            error(message('hdlcommon:workflow:InterfaceOptionsMismatch',InputinterfaceStr,...
            InputportName,OutputinterfaceStr,OutputportName));
        end
    end


