function interfaceStr=getTargetInterface(obj,portName)


    interfaceStr='';
    obj.validateBoardLoaded;
    if obj.isInterfaceTableNeeded
        interfaceStr=obj.hTurnkey.hTable.getInterfaceStr(portName);
    end
end
