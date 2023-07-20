function offsetStr=getTargetOffset(obj,portName)


    offsetStr='';
    obj.validateBoardLoaded;
    if obj.isInterfaceTableNeeded
        offsetStr=obj.hTurnkey.hTable.getBitRangeStr(portName);
    end
end
