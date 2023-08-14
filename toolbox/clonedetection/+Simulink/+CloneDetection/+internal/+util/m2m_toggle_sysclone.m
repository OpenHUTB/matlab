function m2m_toggle_sysclone(m2mObj,sysname,isSelected)





    if isSelected
        m2mObj.include_sysclones(sysname);
    else
        m2mObj.exclude_sysclones(sysname);
    end
end
