function[status,dscr]=CodeCoverageSettings_status(cs,~)


    dscr='';

    isOpen=false;

    if strcmp(get_param(cs.getConfigSetSource,'CoverageDialogOpen'),'on')
        isOpen=true;
    end

    if isa(cs,'Simulink.ConfigSet')
        rtw=cs.getComponent('Code Generation');
    else
        rtw=cs;
    end
    if isOpen||rtw.isReadonlyProperty('RTWBuildHooks')
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end
