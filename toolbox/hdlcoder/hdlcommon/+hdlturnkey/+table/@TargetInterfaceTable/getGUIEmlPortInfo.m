function portInfo=getGUIEmlPortInfo(obj)





    portInfo=struct;
    portNames=cat(2,obj.hIOPortList.InputPortNameList,obj.hIOPortList.OutputPortNameList);
    numPorts=length(portNames);

    for ii=1:numPorts
        portName=portNames{ii};
        try
            hIOPort=obj.hIOPortList.getIOPort(portName);
        catch me %#ok<*NASGU>
            continue
        end
        portInfo(ii).('PortName')=hIOPort.PortName;
        portInfo(ii).('PortType')=hIOPort.getPortTypeStr;
        dispDataType=hIOPort.DispDataType;

        if~hIOPort.isComplex&&~hIOPort.isSingle&&~hIOPort.isDouble&&...
            ~hIOPort.isBus&&~hIOPort.isArrayOfBus


            if hIOPort.Signed
                signedStr='s';
            else
                signedStr='u';
            end

            wordLenStr=num2str(hIOPort.WordLength);
            fracLenStr=num2str(hIOPort.FractionLength);

            dispDataType=[signedStr,'fix',wordLenStr,'_En',fracLenStr];
        end

        portInfo(ii).('DispDataType')=dispDataType;
        portInfo(ii).('InterfaceChoice')=obj.getTableCellInterfaceChoice(portName);
        portInfo(ii).('InterfaceIdx')=obj.hTableMap.getInterfaceIdx(portName);
        portInfo(ii).('BitRange')=obj.hTableMap.getBitRangeStr(portName);
    end

end

