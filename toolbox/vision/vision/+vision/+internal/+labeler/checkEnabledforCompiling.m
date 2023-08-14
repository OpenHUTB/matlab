function flag=checkEnabledforCompiling(appName)

    s=settings;

    if~s.vision.labeler.CompileLabelingApps.ActiveValue

        dialogName=getString(message('vision:labeler:DisabledForCompileTitle'));
        errorMessage=getString(message('vision:labeler:DisabledForCompileMessage',appName));

        vision.internal.labeler.handleAlert([],'errorWithModal',errorMessage,dialogName);

        flag=false;
    else
        flag=true;
    end

end