function[status,dscr]=SignalLoggingConfigure_status(cs,~)



    dscr='';
    if isempty(cs.getConfigSet())||~cs.isActive||cs.isObjectLocked
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end

