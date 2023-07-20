function assignCoProcessingModeInterface(obj)





    hDefaultBusInterface=obj.hTurnkey.getDefaultBusInterface;
    if hDefaultBusInterface.isEmptyAXI4SlaveInterface
        error(message('hdlcommon:workflow:DefaultBusInterface'));
    end

    errorCell={};


    for ii=1:length(obj.hIOPortList.InputPortNameList)
        portName=obj.hIOPortList.InputPortNameList{ii};
        try
            assignCoProcessingModeInterfaceOnPort(obj,portName,hDefaultBusInterface);
        catch ME
            errorStruct.identifier=ME.identifier;
            errorStruct.message=ME.message;
            errorCell{end+1}=errorStruct;%#ok<AGROW>
        end
    end
    for ii=1:length(obj.hIOPortList.OutputPortNameList)
        portName=obj.hIOPortList.OutputPortNameList{ii};
        try
            assignCoProcessingModeInterfaceOnPort(obj,portName,hDefaultBusInterface);
        catch ME
            errorStruct.identifier=ME.identifier;
            errorStruct.message=ME.message;
            errorCell{end+1}=errorStruct;%#ok<AGROW>
        end
    end


    if~isempty(errorCell)
        totalMessageStr='';
        for ii=1:length(errorCell)
            errorStruct=errorCell{ii};
            totalMessageStr=sprintf('%s\n%s',totalMessageStr,errorStruct.message);
        end


        interfaceID=hDefaultBusInterface.InterfaceID;
        warnMsg=message('hdlcommon:workflow:CoProcessorInterface',interfaceID,totalMessageStr);
        cmdDisplay=obj.hTurnkey.hD.cmdDisplay;
        downstream.tool.generateWarning(warnMsg,cmdDisplay);
    end

end