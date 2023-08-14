function validateComplexPort(obj,hIOPort,hTableMap,interfaceStr)

    if hTableMap.hTable.hTurnkey.hStream.isFrameToSampleMode

        flattenedPortWidth=hIOPort.getFlattenedPortWidthStreamingPort;
    else

        flattenedPortWidth=hIOPort.getFlattenedPortWidth;
    end

    if~obj.IsGenericIP

        if isequal(hIOPort.PortType,hdlturnkey.IOType.IN)&&flattenedPortWidth>obj.SlaveChannelDataWidth/2
            error(message('hdlcommon:workflow:UnsupportedComplexPortWidthForAXIStream',interfaceStr,hIOPort.PortName,num2str(obj.SlaveChannelDataWidth/2)));
        end

        if isequal(hIOPort.PortType,hdlturnkey.IOType.OUT)&&flattenedPortWidth>obj.MasterChannelDataWidth/2
            error(message('hdlcommon:workflow:UnsupportedComplexPortWidthForAXIStream',interfaceStr,hIOPort.PortName,num2str(obj.MasterChannelDataWidth/2)));
        end
    end
