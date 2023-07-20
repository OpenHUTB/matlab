function name=validateLogName(~,name)




    if~isvarname(name)
        pm_error('physmod:simscape:logging:sli:settings:InvalidLogName',name);
    end

end
