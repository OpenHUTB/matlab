function parseGUITableRow(obj,tdata,rowIdx)




    colIdx=0;


    colIdx=colIdx+1;
    tdParamItem=tdata{rowIdx,colIdx};
    portNameGUI=tdParamItem.Value;

    lengthInputPort=length(obj.hIOPortList.InputPortNameList);
    if rowIdx<=lengthInputPort
        portNamePIR=obj.hIOPortList.InputPortNameList{rowIdx};
    else
        portNamePIR=obj.hIOPortList.OutputPortNameList{rowIdx-lengthInputPort};
    end

    if~strcmpi(portNameGUI,portNamePIR)
        error(message('hdlcommon:workflow:TablePortNameMismatch',portNameGUI,portNamePIR));
    end
    portName=portNameGUI;


    colIdx=colIdx+1;
    tdParamItem=tdata{rowIdx,colIdx};
    portTypeGUI=tdParamItem.Value;

    hIOPort=obj.hIOPortList.getIOPort(portName);
    portTypePIR=hIOPort.getPortTypeStr;

    if~strcmpi(portTypeGUI,portTypePIR)
        error(message('hdlcommon:workflow:TablePortTypeMismatch',portName,portTypeGUI,portTypePIR));
    end


    colIdx=colIdx+1;
    tdParamItem=tdata{rowIdx,colIdx};
    dataTypeGUI=tdParamItem.Value;
    dataTypePIR=hIOPort.DispDataType;

    if~strcmpi(dataTypeGUI,dataTypePIR)
        error(message('hdlcommon:workflow:TableDataTypeMismatch',portName,dataTypeGUI,dataTypePIR));
    end


    colIdx=colIdx+1;
    tdParamItem=tdata{rowIdx,colIdx};
    interfaceIdxGUI=tdParamItem.Value+1;
    interfaceChoiceGUI=tdParamItem.Entries;
    interfaceStr=interfaceChoiceGUI{interfaceIdxGUI};

    try

        obj.setTableCellInterface(portName,interfaceStr);
    catch ME
        error(message('hdlcommon:workflow:UnableToAssignInterface',interfaceIdxGUI,portName,ME.message));
    end


    colIdx=colIdx+1;
    tdParamItem=tdata{rowIdx,colIdx};
    if obj.hTableMap.isBitRangeComboBox(portName)
        bitrangeIdxGUI=tdParamItem.Value+1;
        bitrangeChoiceGUI=tdParamItem.Entries;
        bitrangeStrGUI=bitrangeChoiceGUI{bitrangeIdxGUI};
    else
        bitrangeStrGUI=tdParamItem.Value;
    end

    try
        obj.setTableCellBitRange(portName,bitrangeStrGUI);
    catch ME
        error(message('hdlcommon:workflow:UnableToAssignBitRange',bitrangeStrGUI,portName,ME.message));
    end

end

