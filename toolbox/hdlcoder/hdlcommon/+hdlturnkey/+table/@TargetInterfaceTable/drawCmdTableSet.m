function drawCmdTableSet(obj)




    if~obj.hTurnkey.hD.cmdDisplay||obj.hTurnkey.hD.cliDisplay
        return;
    end


    if obj.isInterfaceTableEmpty
        obj.populateInterfaceTable;
    end


    [tableSpan,setSpan]=obj.drawCmdTableTitle;


    for ii=1:length(obj.hIOPortList.InputPortNameList)
        portName=obj.hIOPortList.InputPortNameList{ii};
        obj.drawCmdTableRow(portName,tableSpan);
        obj.drawCmdTableRowSet(portName,setSpan);
    end

    for ii=1:length(obj.hIOPortList.OutputPortNameList)
        portName=obj.hIOPortList.OutputPortNameList{ii};
        obj.drawCmdTableRow(portName,tableSpan);
        obj.drawCmdTableRowSet(portName,setSpan);
    end

end