function compileModel(modelName)








    modelRefRebuildChanger=Simulink.variant.utils.ModelReferenceTargetReplacer(modelName);
    modelRefRebuildChanger.changeRebuildOptions();
    set_param(modelName,'SimulationCommand','Update');

end
