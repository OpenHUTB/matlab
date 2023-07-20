function[out,desc]=idelink_AdaptorNameEnum_entries(cs,~)



    if isa(cs,'Simulink.ConfigSet')
        target=cs.getComponent('Code Generation').getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        target=cs.getComponent('Target');
    else
        target=cs;
    end

    out=struct('str',target.ProjectMgr.getAdaptorNames);
    desc='';
