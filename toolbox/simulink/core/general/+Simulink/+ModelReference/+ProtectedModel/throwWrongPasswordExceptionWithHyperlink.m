function throwWrongPasswordExceptionWithHyperlink(modelName,erroringCategories)






    enterPasswordStr=message('Simulink:protectedModel:EncryptPasswordEntryEditBoxText');
    str=message('SL_SERVICES:utils:HotlinkTemplateArg','matlab:Simulink.ModelReference.ProtectedModel.getPasswordFromDialogNonBlocking',...
    ['''',modelName,''''],enterPasswordStr.getString());

    catalogMsg='Simulink:protectedModel:ProtectedModelUnlockWrongPassword';
    exceptionMessage=message(catalogMsg,modelName,erroringCategories,str.getString());
    mExc=MException(exceptionMessage.Identifier,'%s',exceptionMessage.getString());
    mExc.throw;

end

