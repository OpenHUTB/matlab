function isLibrary=isLibraryModel(model)


    if(~stm.internal.util.SimulinkModel.isModelOpenOrLoaded(model))
        load_system(model);
        oc=onCleanup(@()close_system(model));
    end
    isLibrary=bdIsLibrary(model);
end