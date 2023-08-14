function value=getTableCellGUIValue(obj,rowIdx,colIdx)





    InterfaceIdx=3;
    BitRangeIdx=4;


    lengthInputPort=length(obj.hIOPortList.InputPortNameList);
    if rowIdx+1<=lengthInputPort
        portName=obj.hIOPortList.InputPortNameList{rowIdx+1};
    else
        portName=obj.hIOPortList.OutputPortNameList{rowIdx+1-lengthInputPort};
    end


    if colIdx==InterfaceIdx

        value=obj.hTableMap.getInterfaceStr(portName);

    elseif colIdx==BitRangeIdx

        value=obj.hTableMap.getBitRangeStr(portName);

    end

end