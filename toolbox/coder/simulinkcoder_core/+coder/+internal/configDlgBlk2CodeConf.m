function configDlgBlk2CodeConf(action,hDlg,hSrc)%#ok




    if~isa(hSrc,'Simulink.BaseConfig')
        DAStudio.error('RTW:utility:FunctionRequiresConfigSet');
    end

    model=hSrc.getModel;

    if isempty(model)
        return;
    end

    hTraceInfo=get_param(model,'RTWTraceInfo');

    if~isempty(hTraceInfo)&&isa(hTraceInfo,'RTW.TraceInfo')
        dlgID=hTraceInfo.ViewWidget;
    else
        return;
    end

    switch action
    case 'ParentClose'
        if ishandle(dlgID)
            delete(dlgID);
        end
    end



