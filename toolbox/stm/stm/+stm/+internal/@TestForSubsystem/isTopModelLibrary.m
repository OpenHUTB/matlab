function res=isTopModelLibrary(mdl)




    res=false;
    if~bdIsLoaded(mdl)
        load_system(mdl);
    end
    res=bdIsLibrary(mdl);
end

