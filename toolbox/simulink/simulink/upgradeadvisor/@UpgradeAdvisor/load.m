function sysRoot=load(system)




    if ishandle(system)
        system=getfullname(system);
    else
        w=warning('off','Simulink:Commands:LoadingOlderModel');
        c=onCleanup(@()warning(w));
        load_system(system);
        delete(c);
    end


    if exist(system,'file')
        [~,sysRoot]=fileparts(system);
    else
        sysRoot=bdroot(system);
    end

end
