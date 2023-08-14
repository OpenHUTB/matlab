function drawCmdTableRowSet(obj,portName,setSpan)




    interfaceCellStrChoice=obj.getTableCellInterfaceChoice(portName);
    for ii=1:length(interfaceCellStrChoice)
        interfaceStr=interfaceCellStrChoice{ii};
        interfaceLinkStr=sprintf('<a href="matlab:downstream.handle(''Model'',''%s'').hTurnkey.hTable.setInterfaceStrCmd(''%s'', ''%s'');">%s</a>',...
        obj.hTurnkey.hD.hCodeGen.ModelName,portName,interfaceStr,interfaceStr);
        fprintf(setSpan,' ',' ',' ',interfaceLinkStr);%#ok<CTPCT>
    end

end