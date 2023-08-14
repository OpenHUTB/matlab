function[table,header]=drawReportTable(obj)





    tablesetting=hdlturnkey.data.interfaceTableInitFormat;
    header=tablesetting.ColHeader;


    table={};

    for ii=1:length(obj.hIOPortList.InputPortNameList)
        portName=obj.hIOPortList.InputPortNameList{ii};
        table=drawReportTableRow(obj,portName,table);%#ok<*AGROW>
    end

    for ii=1:length(obj.hIOPortList.OutputPortNameList)
        portName=obj.hIOPortList.OutputPortNameList{ii};
        table=drawReportTableRow(obj,portName,table);%#ok<*AGROW>
    end

end
