function tdata=drawGUITableRow(obj,tdata,rowIdx,portName)




    colIdx=0;

    hIOPort=obj.hIOPortList.getIOPort(portName);

    colIdx=colIdx+1;
    tdParamItem=[];
    tdParamItem.Type='edit';
    tdParamItem.Editable=false;
    tdParamItem.Value=portName;
    tdata{rowIdx,colIdx}=tdParamItem;

    colIdx=colIdx+1;
    tdParamItem=[];
    tdParamItem.Type='edit';
    tdParamItem.Editable=false;
    tdParamItem.Value=hIOPort.getPortTypeStr;
    tdata{rowIdx,colIdx}=tdParamItem;

    colIdx=colIdx+1;
    tdParamItem=[];
    tdParamItem.Type='edit';
    tdParamItem.Editable=false;
    tdParamItem.Value=hIOPort.DispDataType;
    tdata{rowIdx,colIdx}=tdParamItem;

    colIdx=colIdx+1;
    tdParamItem=[];
    tdParamItem.Type='combobox';
    tdParamItem.Entries=obj.getTableCellInterfaceChoice(portName);
    tdParamItem.Value=obj.hTableMap.getInterfaceIdx(portName);
    tdata{rowIdx,colIdx}=tdParamItem;

    colIdx=colIdx+1;
    tdParamItem=[];
    if obj.hTableMap.isBitRangeComboBox(portName)
        tdParamItem.Type='combobox';
        tdParamItem.Entries=obj.hTableMap.getBitRangeChoice(portName);
        tdParamItem.Value=obj.hTableMap.getBitRangeIdx(portName);
    else
        tdParamItem.Type='edit';
        tdParamItem.Editable=true;
        tdParamItem.Value=obj.hTableMap.getBitRangeStr(portName);
    end
    tdata{rowIdx,colIdx}=tdParamItem;


    colIdx=colIdx+1;
    tdParamItem=[];
    if obj.hTableMap.showInterfaceOptionPushButton(hIOPort)
        tdParamItem.Type='pushbutton';
        tdParamItem.Name='Options...';
    else

        tdParamItem.Type='text';
        tdParamItem.Editable=false;
    end
    tdata{rowIdx,colIdx}=tdParamItem;

end