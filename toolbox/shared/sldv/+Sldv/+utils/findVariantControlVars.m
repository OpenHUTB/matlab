function variantControlVars=findVariantControlVars(modelName)




    variantControlVars=[];
    try
        variantControlVars=Simulink.VariantManager.findVariantControlVars(modelName);
    catch MEx


















        if any(strcmp(MEx.identifier,slvariants.internal.utils.getVMgrSPKGMissingMessageIDs()))
            return;
        end
    end
end


