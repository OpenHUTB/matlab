function newvalue=setExtModeTransport(hSrc,value)






    if isempty(hSrc.getConfigSet)
        newvalue=value;
        return;
    end

    [~,mexfile_list,interface_list]=extmode_transports(hSrc.getConfigSet);

    if~hSrc.isObjectLocked
        hSrc.ExtModeMexFile=mexfile_list{value+1};
        hSrc.ExtModeIntrfLevel=interface_list{value+1};
    end

    newvalue=value;
