function cont=launchDialog(modelName)



    if isnumeric(modelName)
        modelName=getfullname(modelName);
    end
    cancel=message('SimulinkCoderApp:ui:LaunchCancelBtn').getString;
    question=message('SimulinkCoderApp:ui:LaunchQuestion',modelName).getString;
    title=message('SimulinkCoderApp:ui:LaunchTitle',modelName).getString;
    qsLaunch=message('SimulinkCoderApp:ui:LaunchQuickStartBtn').getString;
    switchTarget=message('SimulinkCoderApp:ui:LaunchSwitchToERTBtn').getString;
    buttonPressed=questdlg(question,title,qsLaunch,switchTarget,cancel,qsLaunch);
    switch buttonPressed
    case qsLaunch
        coder.internal.wizard.slcoderWizard(modelName,'Start');
        cont=false;
    case switchTarget
        set_param(modelName,'SystemTargetFile','ert.tlc');
        cont=true;
    case cancel
        cont=false;
    otherwise
        cont=false;
    end
end