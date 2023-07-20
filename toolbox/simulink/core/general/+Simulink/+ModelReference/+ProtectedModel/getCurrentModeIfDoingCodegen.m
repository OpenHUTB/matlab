function out=getCurrentModeIfDoingCodegen(model)





    out='';
    if~isempty(model)&&bdIsLoaded(model)
        creator=Simulink.ModelReference.ProtectedModel.getCreatorDuringProtection(model);
        if~isempty(creator)&&creator.supportsCodeGen()
            out=creator.currentMode;
        end
    end
end