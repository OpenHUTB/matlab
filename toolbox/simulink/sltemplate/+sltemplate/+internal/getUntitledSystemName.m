function sysName=getUntitledSystemName










    sysName='untitled';
    if is_simulink_loaded
        sysName=slInternal('getNewModelName');
    end
end
