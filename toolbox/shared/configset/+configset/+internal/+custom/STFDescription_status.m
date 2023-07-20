function[status,dscr]=STFDescription_status(cs,~)


    dscr='';


    if isa(cs,'Simulink.ConfigSet')
        rtw=cs.getComponent('Code Generation');
    elseif isa(cs,'Simulink.RTWCC')
        rtw=cs;
    end

    if isempty(rtw.getProp('Description'))
        status=configset.internal.data.ParamStatus.UnAvailable;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end

end

