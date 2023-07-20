function tablesetting=drawGUITable(obj)





    tablesetting=hdlturnkey.data.interfaceTableInitFormat;


    lengthInputPort=length(obj.hIOPortList.InputPortNameList);
    lengthOutputPort=length(obj.hIOPortList.OutputPortNameList);
    tableRowNum=lengthInputPort+lengthOutputPort;
    tableColumnNum=length(tablesetting.ColHeader);
    tablesetting.Size=[tableRowNum,tableColumnNum];


    tdata=cell(tableRowNum,tableColumnNum);


    for ii=1:length(obj.hIOPortList.InputPortNameList)
        portName=obj.hIOPortList.InputPortNameList{ii};
        tdata=obj.drawGUITableRow(tdata,ii,portName);
    end

    for ii=1:length(obj.hIOPortList.OutputPortNameList)
        portName=obj.hIOPortList.OutputPortNameList{ii};
        tdata=obj.drawGUITableRow(tdata,lengthInputPort+ii,portName);
    end

    tablesetting.Data=tdata;

end
