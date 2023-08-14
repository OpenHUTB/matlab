function[accessibleCtrlVarsIdxs,structCtrlVars]=pushControlVariables(rootModelName,modelName,controlVarsStruct,varargin)







    numCtrlVars=numel(controlVarsStruct);
    accessibleCtrlVarsIdxs=false(1,numCtrlVars);
    modelSource=get_param(modelName,'DataDictionary');

    referencedDDsOfModel=Simulink.variant.utils.slddaccess.getAllReferencedDataDictionaries(modelName);
    rootModelSource=get_param(rootModelName,'DataDictionary');

    if numel(varargin)>=1
        optArgs=varargin{1};
    else
        optArgs=struct();
    end
    skipSourceAccessCheck=isfield(optArgs,'SkipSourceAccessCheck')&&optArgs.SkipSourceAccessCheck;

    for i=1:numCtrlVars
        ctrlVar=controlVarsStruct(i);
        if~isfield(ctrlVar,'Source')||isempty(convertStringsToChars(strtrim(ctrlVar.Source)))

            ctrlVar.Source=rootModelSource;
        elseif strcmp(ctrlVar.Source,slvariants.internal.config.utils.getGlobalWorkspaceName_R2020b(''))

            ctrlVar.Source=slvariants.internal.config.utils.getGlobalWorkspaceName('');
        end
        if skipSourceAccessCheck||...
            Simulink.variant.utils.slddaccess.isSourceAccessibleForModel(modelName,modelSource,ctrlVar.Source,referencedDDsOfModel)
            accessibleCtrlVarsIdxs(i)=true;

            if~isvarname(ctrlVar.Name)
                controlVarsStruct(i)=ctrlVar;
                continue;
            end

            if strcmp(ctrlVar.Source,slvariants.internal.config.utils.getGlobalWorkspaceName(''))

                ddSpec='';
            else
                ddSpec=ctrlVar.Source;
            end
            ctrlVarValue=Simulink.variant.utils.deepCopy(ctrlVar.Value,'ErrorForNonCopyableHandles',false);
            Simulink.variant.utils.slddaccess.assignInGlobalScopeOfDataDictionary(ctrlVar.Name,ctrlVarValue,ddSpec);
        end
    end


    structCtrlVars=slvariants.internal.config.getCollatedStruct(controlVarsStruct,accessibleCtrlVarsIdxs);
    for i=1:numel(structCtrlVars)
        ctrlVar=structCtrlVars(i);
        if strcmp(ctrlVar.Source,slvariants.internal.config.utils.getGlobalWorkspaceName(''))

            ddSpec='';
        else
            ddSpec=ctrlVar.Source;
        end
        Simulink.variant.utils.slddaccess.assignInGlobalScopeOfDataDictionary(ctrlVar.Name,ctrlVar.Value,ddSpec);
    end
end


