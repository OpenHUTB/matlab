function[ctrlVars,ctrlVarsUsageMap]=getVariantControlVarInBlocksWithSources(modelName,varargin)










    ctrlVarsUsageMap=containers.Map;

    load_system(modelName);
    bdH=get_param(modelName,'Handle');
    searchReferencedModels=true;
    if numel(varargin)>0
        searchReferencedModels=varargin{1};
    end
    warnState=warning('off');
    warnStateCleanup=onCleanup(@()warning(warnState));
    usageInfoForHierarchy=slvariants.internal.manager.core.getVariantControlUsageInfo(bdH,searchReferencedModels);
    warnStateCleanup=[];%#ok<NASGU>
    usageInfoPerModelMap=usageInfoForHierarchy.UsageInfo;

    modelNames=usageInfoPerModelMap.keys();

    for m=1:numel(modelNames)
        model=modelNames{m};
        ddName=get_param(model,'DataDictionary');
        usageInfoPerModel=usageInfoPerModelMap.getByKey(model);

        varCtrlsMap=usageInfoPerModel.varCtrlInfo;
        varCtrls=varCtrlsMap.keys();
        for v=1:numel(varCtrls)
            if~ctrlVarsUsageMap.isKey(varCtrls{v})
                ctrlVarsUsageMap(varCtrls{v})={};
            end
            if~any(strcmp(ctrlVarsUsageMap(varCtrls{v}),ddName))
                ctrlVarsUsageMap(varCtrls{v})=[ctrlVarsUsageMap(varCtrls{v}),{ddName}];
            end
        end

        varParamsMap=usageInfoPerModel.varCtrlParamInfo;
        varParams=varParamsMap.keys;
        for k=1:numel(varParams)
            varCtrls=varParamsMap.getByKey(varParams{k}).VariantControlVars;
            for v=1:double(varCtrls.Size)
                if~ctrlVarsUsageMap.isKey(varParams{k})
                    ctrlVarsUsageMap(varCtrls.at(v))={};
                end
                ctrlVarsUsageMap(varCtrls.at(v))=[ctrlVarsUsageMap(varCtrls.at(v)),{ddName}];
            end
        end
    end
    ctrlVars=ctrlVarsUsageMap.keys;
end