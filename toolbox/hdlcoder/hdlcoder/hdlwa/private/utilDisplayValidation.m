function[ResultDescription,ResultDetails,hasError]=utilDisplayValidation(validateCell,...
    ResultDescription,ResultDetails)





    hasError=false;
    validateCellError={};
    validateCellOther={};
    for ii=1:length(validateCell)
        validateStruct=validateCell{ii};
        validateStatus=validateStruct.Status;

        if ischar(validateStatus)&&strcmpi(validateStatus,'Error')
            validateCellError{end+1}=validateStruct;
            hasError=true;
        else
            validateCellOther{end+1}=validateStruct;
        end
    end


    [ResultDescription,ResultDetails]=utilDisplayValidationPrivate(validateCellError,...
    ResultDescription,ResultDetails);


    [ResultDescription,ResultDetails]=utilDisplayValidationPrivate(validateCellOther,...
    ResultDescription,ResultDetails);
end

function[ResultDescription,ResultDetails]=utilDisplayValidationPrivate(validateCell,...
    ResultDescription,ResultDetails)

    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});
    Warning=ModelAdvisor.Text('Warning ',{'Warn'});
    Note=ModelAdvisor.Text('Note ',{'bold'});

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
            ResultDescription{end+1}=ModelAdvisor.Text([Failed.emitHTML,validateStruct.Message]);%#ok<*AGROW>
            ResultDetails{end+1}='';

        elseif status==2
            ResultDescription{end+1}=ModelAdvisor.Text([Warning.emitHTML,validateStruct.Message]);
            ResultDetails{end+1}='';
        elseif status==0
            ResultDescription{end+1}=ModelAdvisor.Text([Note.emitHTML,validateStruct.Message]);
            ResultDetails{end+1}='';
        end
    end

end


