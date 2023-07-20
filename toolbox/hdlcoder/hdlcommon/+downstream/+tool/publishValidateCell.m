function msgStr=publishValidateCell(validateCell)










    validateCell=downstream.tool.filterEmptyCell(validateCell);

    msgStr='';
    for ii=1:length(validateCell)
        validateStruct=validateCell{ii};
        validateStatus=validateStruct.Status;




        if ischar(validateStatus)
            if strcmpi(validateStatus,'Error')
                status=1;
            elseif strcmpi(validateStatus,'Warning')
                status=2;
            else
                status=0;
            end
        else
            status=validateStatus;
        end

        if status==1
            msgStr=sprintf('%sError: %s\n',msgStr,validateStruct.Message);
        elseif status==2
            msgStr=sprintf('%sWarning: %s\n',msgStr,validateStruct.Message);
        elseif status==0
            msgStr=sprintf('%Note: %s\n',msgStr,validateStruct.Message);
        end
    end

end

