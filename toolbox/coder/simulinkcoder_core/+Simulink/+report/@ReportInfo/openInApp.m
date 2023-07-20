function openInApp(obj,url)
    if isempty(obj.SourceSubsystem)
        model=obj.ModelName;
    else
        model=bdroot(obj.SourceSubsystem);
    end
    wizard=get_param(model,'CoderWizard');
    if isempty(wizard)
        coder.internal.wizard.slcoderWizard(model,'Start');
        wizard=get_param(model,'CoderWizard');
    end
    url=loc_getFileUrl(url);
    url=[url,'&inApp=true'];
    wizard.Gui.openReport(url);
end
