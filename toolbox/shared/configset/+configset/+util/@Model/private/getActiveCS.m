function cs=getActiveCS(mdl)

    if bdIsLoaded(mdl)
        cs=getActiveConfigSet(mdl);
    else
        load_system(mdl);
        cs=getActiveConfigSet(mdl);
        close_system(mdl,0);
    end
