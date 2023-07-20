function validateModel(obj)






    for ii=1:length(obj.hIOPortList.InputPortNameList)
        portName=obj.hIOPortList.InputPortNameList{ii};
        hIOPort=obj.hIOPortList.getIOPort(portName);
        obj.validatePort(hIOPort);
    end

    for ii=1:length(obj.hIOPortList.OutputPortNameList)
        portName=obj.hIOPortList.OutputPortNameList{ii};
        hIOPort=obj.hIOPortList.getIOPort(portName);
        obj.validatePort(hIOPort);
    end




end