
function m2m_toggle_const(system,const,check)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    m2m_obj=mdladvObj.UserData;
    if check
        m2m_obj.include_const(const);
    else
        m2m_obj.exclude_const(const);
    end






end