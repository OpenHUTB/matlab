function success=openOrThrowToMessageViewer(parentName,modelName)









    import Simulink.ModelReference.ProtectedModel.*;

    stageName=DAStudio.message('Simulink:protectedModel:ProtectedModelLoadMessageViewerStageName');
    stageObj=Simulink.output.Stage(stageName,'ModelName',parentName,'UIMode',true);%#ok<NASGU>
    isEncrypted=PasswordManager.isEncryptionCategoryEncrypted(modelName,'VIEW');
    success=true;
    if isEncrypted
        rightPassword=PasswordManager.doesEncryptionCategoryHaveTheRightPassword(modelName,'VIEW');
        if~rightPassword
            exc=getWrongPasswordDetailedException(modelName,'VIEW');
            Simulink.output.error(exc);
            success=false;
        end
    end
end