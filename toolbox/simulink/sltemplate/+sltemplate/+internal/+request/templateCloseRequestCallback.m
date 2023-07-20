function templateCloseRequestCallback(bd)




    if strcmpi(get_param(bd,"Dirty"),"off")
        return
    end

    title=message("Simulink:editor:DialogMessage").getString();
    msg=message("sltemplate:Editor:SaveBeforeClosing",get_param(bd,"Name")).getString();
    YesButton=message('MATLAB:uistring:popupdialogs:Yes').getString();
    NoButton=message('MATLAB:uistring:popupdialogs:No').getString();
    CancelButton=message('MATLAB:uistring:popupdialogs:Cancel').getString();
    ButtonName=questdlg(msg,title,YesButton,NoButton,CancelButton,YesButton);
    switch ButtonName
    case YesButton
        blocker=SLM3I.ScopedStudioBlocker(bd);
        cleanup=onCleanup(@()delete(blocker));

        try
            Simulink.saveTemplate(bd,get_param(bd,'TemplateFilePath'));
        catch ME
            uiwait(errordlg(ME.message,message("sltemplate:Editor:ErrorSavingTemplateTitle").getString(),'modal'));
            error('Simulink:Commands:CancelCloseModel','Cancel model close');
        end

        delete(cleanup);
    case NoButton
        set_param(bd,"Dirty","off");
    case CancelButton
        error('Simulink:Commands:CancelCloseModel','Cancel model close');
    end
end
