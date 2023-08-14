function isCompiled=isModelCompiled(model)







    modelH=slreportgen.utils.getModelHandle(model);
    status=get_param(modelH,"SimulationStatus");
    isCompiled=strcmp(status,"paused");

end

