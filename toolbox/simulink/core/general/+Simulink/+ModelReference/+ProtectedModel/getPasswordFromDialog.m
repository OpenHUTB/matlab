function getPasswordFromDialog(currentProtectedModel,iMdl,category,isMenuSim,varargin)











    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;

    assert(strcmp(category,'SIM')||strcmp(category,'RTW')||strcmp(category,'VIEW')||strcmp(category,'HDL'),'Category can only be SIM, RTW, VIEW or HDL');

    if isempty(varargin)
        if~PasswordManager.isEncryptionCategoryEncrypted(currentProtectedModel,category)||...
            PasswordManager.doesEncryptionCategoryHaveTheRightPassword(currentProtectedModel,category)
            return;
        end
    else
        opts=varargin{1};
        if~PasswordManager.isEncryptionCategoryEncryptedOpts(category,opts)||...
            PasswordManager.doesEncryptionCategoryHaveTheRightPassword(currentProtectedModel,category)
            return;
        end
    end






    disblePasswordentry=disableGUIPassword('get');
    if~isMenuSim||...
        disblePasswordentry||...
        slsvTestingHook('ProtectedModelNonBlocking')||...
        ~isempty(PasswordManager.getPasswordForEncryptionCategory(currentProtectedModel,category))

        wrongPasswordException=getWrongPasswordDetailedException(currentProtectedModel,category);
        wrongPasswordException.throw;
    end

    if strcmp(category,'SIM')
        relationship='modelReferenceSimTarget';
    elseif strcmp(category,'VIEW')
        relationship='webview';
    elseif strcmp(category,'RTW')
        currentTarget=getCurrentTarget(currentProtectedModel);
        relationship=constructTargetRelationshipName('rtwsharedutils',currentTarget);
    else
        relationship='hdl';
    end

    result=getPasswordFromDialogForUnlock(currentProtectedModel,true,relationship,true,iMdl,false,[],true);
    while strcmp(result,'WrongPassword')
        result=getPasswordFromDialogForUnlock(currentProtectedModel,true,relationship,false,iMdl,false,[],true);
    end



    if~strcmp(result,'Done')
        wrongPasswordException=getWrongPasswordDetailedException(currentProtectedModel,category);
        wrongPasswordException.throw;
    end
end

