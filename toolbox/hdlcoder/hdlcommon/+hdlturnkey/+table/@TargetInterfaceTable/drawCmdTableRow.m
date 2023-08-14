function drawCmdTableRow(obj,portName,tableSpan)





    hIOPort=obj.hIOPortList.getIOPort(portName);
    portNameStr=portName;
    portTypeStr=hIOPort.getPortTypeStr;
    portDataType=hIOPort.DispDataType;

    interfaceStr=obj.hTableMap.getInterfaceStr(portName);

    bitrangeStr=obj.hTableMap.getBitRangeStr(portName);

    fprintf(tableSpan,portNameStr,portTypeStr,portDataType,interfaceStr,bitrangeStr);

end

