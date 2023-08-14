function out=getWrongPasswordDetailedException(modelName,category)









    enterPasswordStr=message('Simulink:protectedModel:EncryptPasswordEntryEditBoxText');
    str=message('SL_SERVICES:utils:HotlinkTemplateArg','matlab:Simulink.ModelReference.ProtectedModel.getPasswordFromDialogNonBlocking',...
    ['''',modelName,''''],enterPasswordStr.getString());

    switch category
    case 'SIM'
        catalogMsg='Simulink:protectedModel:ProtectedModelWrongPasswordDetailedSim';
    case 'RTW'
        catalogMsg='Simulink:protectedModel:ProtectedModelWrongPasswordDetailedCodeGen';
    case 'VIEW'
        catalogMsg='Simulink:protectedModel:ProtectedModelWrongPasswordDetailedView';
    case 'MODIFY'
        catalogMsg='Simulink:protectedModel:ProtectedModelWrongPasswordDetailedModify';
    otherwise
        assert(false,'Incorrect category');
    end
    exceptionMessage=message(catalogMsg,modelName,str.getString());
    out=MException(exceptionMessage.Identifier,'%s',exceptionMessage.getString());
end


