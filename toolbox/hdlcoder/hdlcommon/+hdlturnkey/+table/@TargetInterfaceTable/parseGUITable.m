function parseGUITable(obj,tablesetting)





    tsize=tablesetting.Size;
    lengthInputPort=length(obj.hIOPortList.InputPortNameList);
    lengthOutputPort=length(obj.hIOPortList.OutputPortNameList);
    tableRowNum=lengthInputPort+lengthOutputPort;
    if~isequal(tsize(1),tableRowNum)
        error(message('hdlcommon:workflow:TableSizeMismatch'));
    end


    tdata=tablesetting.Data;

    for ii=1:tableRowNum
        obj.parseGUITableRow(tdata,ii);
    end

end
