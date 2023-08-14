function displayValidateCell(validateCell)














    for ii=1:length(validateCell)
        validateStruct=validateCell{ii};
        validateStatus=validateStruct.Status;

        if strcmp(validateStatus,'Error')
            error(validateStruct.MessageID,downstream.tool.replaceBackSlash(validateStruct.Message));
        elseif strcmp(validateStatus,'Warning')
            warning(validateStruct.MessageID,downstream.tool.replaceBackSlash(validateStruct.Message));
        else
            display(validateStruct.Message);
        end
    end

end


