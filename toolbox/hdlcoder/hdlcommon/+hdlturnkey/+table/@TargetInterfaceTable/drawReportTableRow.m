function table=drawReportTableRow(obj,portName,table)





    hIOPort=obj.hIOPortList.getIOPort(portName);

    if hIOPort.isTunable


        portNameLink=obj.hTurnkey.hD.hIP.hIPEmitter.hReport.generateSystemLink(hIOPort.CompFullName);

        portNameLink.content=portName;
    elseif hIOPort.isTestPoint


        portNameLink=hIOPort.getTestPointLink();
    else

        dutName=obj.hTurnkey.hD.hCodeGen.getDutName;
        portBlkPath=[dutName,'/',portName];
        portNameLink=obj.hTurnkey.hD.hIP.hIPEmitter.hReport.generateSystemLink(portBlkPath);
    end


    portTypeStr=hIOPort.getPortTypeStr;


    portDataType=hIOPort.DispDataType;


    interfaceStr=obj.hTableMap.getInterfaceStr(portName);


    bitrangeStr=obj.hTableMap.getBitRangeStr(portName);


    interfaceOptStr=obj.hTableMap.getInterfaceOptionStr(portName);


    table{end+1}={portNameLink,portTypeStr,portDataType,interfaceStr,bitrangeStr,interfaceOptStr};


    if~hIOPort.isBus
        return;
    end


    if~(strcmpi(interfaceStr,'AXI4')||strcmpi(interfaceStr,'AXI4-lite'))
        return;
    end


    hInterface=obj.hTableMap.getInterface(portName);
    hAddrList=hInterface.hAddrManager.getAddressWithName(portName);


    table{end}={portNameLink,portTypeStr,portDataType,interfaceStr,'',interfaceOptStr};
    table=obj.drawReportTableRowBus(table,...
    interfaceStr,interfaceOptStr,...
    hAddrList,hIOPort,portName);


end