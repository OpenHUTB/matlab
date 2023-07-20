function newvalue=setExtModeTransport(hSrc,value)






    if isempty(hSrc.getConfigSet)
        newvalue=value;
        return;
    end

    [~,mexfile_list,interface_list]=extmode_transports(hSrc.getConfigSet);



    if value+1>length(mexfile_list)
        DAStudio.error('Simulink:Extmode:ExtModeTransportNotAvailable',...
        num2str(value));
        newvalue=value;
        return;
    end

    if~hSrc.isObjectLocked
        hSrc.ExtModeMexFile=mexfile_list{value+1};
        hSrc.ExtModeIntrfLevel=interface_list{value+1};
    end

    newvalue=value;
