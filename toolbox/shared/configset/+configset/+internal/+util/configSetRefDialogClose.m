function configSetRefDialogClose(ref)





    if slfeature('ConfigSetRefOverride')>1
        ref.getConfigSetCache.getDialogController.csv2=[];
    else
        ref.getDialogController.csv2=[];
    end


    source=ref.getConfigSetSource;
    if isa(source,'Simulink.ConfigSetRef')
        source.destroyDialogCache;
    end
