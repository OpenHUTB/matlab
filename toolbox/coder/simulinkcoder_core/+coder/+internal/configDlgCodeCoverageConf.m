function configDlgCodeCoverageConf(action,hDlg,hSrc)%#ok




    if~isa(hSrc,'Simulink.BaseConfig')
        DAStudio.error('RTW:utility:FunctionRequiresConfigSet');
    end

    model=hSrc.getModel;

    if isempty(model)
        return;
    end

    hCodeCoverage=get_param(model,'RTWCodeCoverage');

    if~isempty(hCodeCoverage)&&isa(hCodeCoverage,'coder_coverage_ui.CodeCovDlg')
        dlgID=hCodeCoverage.ViewWidget;
        set_param(model,'RTWCodeCoverage',[]);
    else
        return;
    end

    switch action
    case 'ParentClose'
        if ishandle(dlgID)
            delete(dlgID);
        end
    end



