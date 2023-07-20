function[status,dscr]=showCcsLoadProgram(cs,~)



    dscr='';

    if isa(cs,'CCSTargetConfig.HostTargetConfig')
        comp=cs;
    elseif isa(cs,'Simulink.ConfigSet')
        comp=cs.getComponent('Host-Target Communication');
    end

    if isempty(comp.getComponent('RTDX Configuration'))
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.UnAvailable;
    end

