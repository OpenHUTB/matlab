function m2m_toggle_dsm(system,candIdx,check)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    m2m_obj=mdladvObj.UserData;
    if check
        m2m_obj.includeCandidatesIndex(str2num(candIdx));
    else
        m2m_obj.excludeCandidatesIndex(str2num(candIdx));
    end

    m2m_refresh_dsm(mdladvObj);
end
