function dlo=getLoggingOverride(mdl)



    dlo=get_param(mdl,'DataLoggingOverride');
    if~isempty(dlo)
        sw=warning('off','all');
        tmp=onCleanup(@()warning(sw));
        dlo=validate(dlo,mdl,false,false,true,'remove');
    end
end
