function configSet=utilGetActiveConfigSet(model)





    fileOpened=ismember(model,find_system('type','block_diagram'));

    if(~fileOpened)
        load_system(model);
    end

    cfs=getActiveConfigSet(model);

    if isa(cfs,'Simulink.ConfigSetRef')
        configSet.configSet=cfs.getRefConfigSet;
        configSet.isConfigSetRef=true;
    else
        configSet.configSet=cfs;
        configSet.isConfigSetRef=false;
    end

    if(~fileOpened)
        close_system(model);
    end
