function[st,dscr]=LaunchModelAdvisor_status(cs,~)





    dscr='Enabled on model active configset';

    if isa(cs,'Simulink.RTWCC')
        cs=cs.getConfigSet;
    end

    if isempty(cs)||isempty(cs.getModel)||(cs.isActive==0)||...
        strcmp(get_param(cs.getModel,'name'),'DefaultBlockDiagram')||...
        cs.isObjectLocked
        st=configset.internal.data.ParamStatus.ReadOnly;
    else
        st=configset.internal.data.ParamStatus.Normal;
    end

