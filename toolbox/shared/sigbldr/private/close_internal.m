function close_internal(UD)






    sigBuilderImportFile(UD.dialog,'close');



    if is_simulating_l(UD)
        set(UD.dialog,'Visible','off');
        return;
    end

    if UD.common.dirtyFlag==1
        UD=save_session(UD);
    end

    if~isempty(UD.simulink)
        sigbuilder_block('figClose',UD.simulink);
    end

    if vnv_rmi_installed&&isfield(UD,'verify')&&isfield(UD.verify,'jVerifyPanel')&&...
        ~isempty(UD.verify.jVerifyPanel)
        vnv_panel_mgr('sbClosePanel',UD.simulink.subsysH,UD.verify.jVerifyPanel);
    end

    delete(UD.dialog);


    modelH=UD.simulink.modelH;
    blockH=UD.simulink.subsysH;
    modelObject=get_param(modelH,'object');
    id=matlab.lang.makeValidName(getfullname(blockH));

    if modelObject.hasCallback('PreClose',id)
        modelObject.removeCallback('PreClose',id);
    end