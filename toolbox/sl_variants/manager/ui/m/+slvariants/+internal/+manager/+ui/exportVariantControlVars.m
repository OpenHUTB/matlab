function exportVariantControlVars(~,configDlgSchema)








    modelName=configDlgSchema.BDName;
    ctrlVarSSSrc=configDlgSchema.CtrlVarSSSrc;
    if isempty(ctrlVarSSSrc.Children)
        return;
    end



    optArgs.SkipSourceAccessCheck=true;
    slvariants.internal.manager.core.pushControlVariables(modelName,modelName,ctrlVarSSSrc.getControlVarStruct(),optArgs);
end
