function validateCell=validateFullTable(obj,validateCell,hTable)





    validateCell=obj.hChannelList.validateFullTable(validateCell,hTable);




    if~hTable.hTurnkey.hD.isMLHDLC&&obj.isFrameToSample
        hN=hTable.hTurnkey.getPirInstance.getTopNetwork;
        portInfo=streamingmatrix.getStreamedPorts(hN);
        if(isempty(portInfo.streamedInPorts))
            validateCell{end+1}=hdlvalidatestruct('Warning',...
            message('hdlcommon:streamingmatrix:GlobalPortMismatch_NoPort'));
        end
    end

    for ii=1:length(hTable.hIOPortList.InputPortNameList)
        portName=hTable.hIOPortList.InputPortNameList{ii};
        hIOPort=hTable.hIOPortList.getIOPort(portName);
        interfaceStr=hTable.hTableMap.getInterfaceStr(portName);
        hInterface=hTable.hTableMap.getInterface(portName);
        if hIOPort.isVector&&hInterface.isIPInterface&&hInterface.isAXI4StreamInterface

            if strcmp(obj.SamplePackingDimension,'None')





                if~obj.isFrameToSample

                    obj.validateVectorPortFrameMode(hIOPort,hTable.hTableMap,interfaceStr);
                end
            elseif strcmp(obj.SamplePackingDimension,'All')




                obj.validateVectorPortSampleMode(hIOPort,hTable.hTableMap,interfaceStr);
            end
        end
    end

    for ii=1:length(hTable.hIOPortList.OutputPortNameList)
        portName=hTable.hIOPortList.OutputPortNameList{ii};
        hIOPort=hTable.hIOPortList.getIOPort(portName);
        interfaceStr=hTable.hTableMap.getInterfaceStr(portName);
        hInterface=hTable.hTableMap.getInterface(portName);
        if hIOPort.isVector&&hInterface.isIPInterface&&hInterface.isAXI4StreamInterface

            if strcmp(obj.SamplePackingDimension,'None')
                if~obj.isFrameToSample

                    obj.validateVectorPortFrameMode(hIOPort,hTable.hTableMap,interfaceStr);
                end
            elseif strcmp(obj.SamplePackingDimension,'All')
                obj.validateVectorPortSampleMode(hIOPort,hTable.hTableMap,interfaceStr);
            end
        end
    end
end

