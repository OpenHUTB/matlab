function m2m_toggle_sysclone(m2mObj,sysname,check)


    if check
        m2mObj.include_sysclones(sysname);
    else
        m2mObj.exclude_sysclones(sysname);
    end
end