function drawCmdTable(obj,populateTable)




    if nargin<2
        populateTable=false;
    end


    if obj.isInterfaceTableEmpty||populateTable
        obj.populateInterfaceTable;
    end


    if~obj.hTurnkey.hD.cmdDisplay||obj.hTurnkey.hD.cliDisplay
        return;
    end


    tableSpan=obj.drawCmdTableTitle;


    for ii=1:length(obj.hIOPortList.InputPortNameList)
        portName=obj.hIOPortList.InputPortNameList{ii};
        obj.drawCmdTableRow(portName,tableSpan);
    end

    for ii=1:length(obj.hIOPortList.OutputPortNameList)
        portName=obj.hIOPortList.OutputPortNameList{ii};
        obj.drawCmdTableRow(portName,tableSpan);
    end

end