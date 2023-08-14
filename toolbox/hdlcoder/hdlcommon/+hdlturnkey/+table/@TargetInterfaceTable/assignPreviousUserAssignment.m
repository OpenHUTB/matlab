function assignPreviousUserAssignment(obj)





    if obj.hIOPortListRef.IOPortMap.isempty;
        return;
    end

    errorCell={};


    for ii=1:length(obj.hIOPortList.InputPortNameList);
        portName=obj.hIOPortList.InputPortNameList{ii};
        try
            obj.assignPreviousUserAssignmentOnPort(portName);
        catch ME
            errorStruct.identifier=ME.identifier;
            errorStruct.message=ME.message;
            errorCell{end+1}=errorStruct;%#ok<AGROW>
        end
    end

    for ii=1:length(obj.hIOPortList.OutputPortNameList);
        portName=obj.hIOPortList.OutputPortNameList{ii};
        try
            obj.assignPreviousUserAssignmentOnPort(portName);
        catch ME
            errorStruct.identifier=ME.identifier;
            errorStruct.message=ME.message;
            errorCell{end+1}=errorStruct;%#ok<AGROW>
        end
    end


    if~isempty(errorCell)
        messageID='';
        messageStr='';
        for ii=1:length(errorCell)
            errorStruct=errorCell{ii};
            messageStr=sprintf('%s\n%s',messageStr,errorStruct.message);
            if ii==1
                messageID=errorStruct.identifier;
            end
        end
        error(messageID,messageStr);
    end

end