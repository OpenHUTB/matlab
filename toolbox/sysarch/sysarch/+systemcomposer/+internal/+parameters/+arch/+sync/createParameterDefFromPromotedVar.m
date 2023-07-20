function createParameterDefFromPromotedVar(arch,prmName,var,mdlName)





    import systemcomposer.internal.parameters.arch.sync.*

    paramDef=systemcomposer.internal.arch.internal.getOrAddParamDef(arch,prmName);
    doWarning=systemcomposer.internal.arch.internal.parameterSyncWarningStatus;

    if~isempty(paramDef)

        syncValue(paramDef,var,mdlName,doWarning);
        syncUnit(paramDef,var,doWarning);
        syncDataType(paramDef,var,mdlName,doWarning);
        syncDimensions(paramDef,var,doWarning);
        syncComplexity(paramDef,var,doWarning);
        syncMin(paramDef,var,doWarning);
        syncMax(paramDef,var,doWarning);
    end

end