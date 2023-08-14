function[ctrlVars,ctrlVarsBlockUsageMap,ctrlVarsParamUsageMap]=getVariantControlVarsWithUsages(modelName,varargin)










    ctrlVarsBlockUsageMap=containers.Map;
    ctrlVarsParamUsageMap=containers.Map;

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


        usageInfoPerModel=usageInfoPerModelMap.getByKey(model);
        modelBlockPathsRootModel=usageInfoPerModel.ModelBlockPathsRootModel.toArray();

        varCtrlsMap=usageInfoPerModel.varCtrlInfo;
        varCtrls=varCtrlsMap.keys();

        for v=1:numel(varCtrls)
            if~ctrlVarsBlockUsageMap.isKey(varCtrls{v})

                ctrlVarsBlockUsageMap(varCtrls{v})=[];
            end

            blocksWithVarCtrl=usageInfoPerModel.varCtrlInfo.getByKey(varCtrls{v}).BlocksWithVarControl;
            for b=1:double(blocksWithVarCtrl.Size)
                blockPath=blocksWithVarCtrl.at(b).getBlockPathImpl();
                indexOfModelNamePart=strfind(blockPath,'/');
                for i=1:numel(modelBlockPathsRootModel)
                    blockPathRootModel=[modelBlockPathsRootModel{i},blockPath(indexOfModelNamePart:end)];
                    BlockPaths=struct('RootModelPath',blockPathRootModel,'ParentModelPath',blockPath);
                    ctrlVarsBlockUsageMap(varCtrls{v})=[ctrlVarsBlockUsageMap(varCtrls{v}),BlockPaths];
                end
            end
            usagesOfVarCtrl=ctrlVarsBlockUsageMap(varCtrls{v});
            [~,idxs]=unique({usagesOfVarCtrl(:).RootModelPath});
            usagesOfVarCtrl=usagesOfVarCtrl(idxs);
            ctrlVarsBlockUsageMap(varCtrls{v})=usagesOfVarCtrl;
        end


        varParamsMap=usageInfoPerModel.varCtrlParamInfo;
        varParams=varParamsMap.keys;
        for k=1:numel(varParams)
            varCtrls=varParamsMap.getByKey(varParams{k}).VariantControlVars;
            for v=1:double(varCtrls.Size)
                if~ctrlVarsParamUsageMap.isKey(varCtrls.at(v))
                    ctrlVarsParamUsageMap(varCtrls.at(v))=[];
                end
                for i=1:numel(modelBlockPathsRootModel)
                    BlockPaths=struct('RootModelPath',modelBlockPathsRootModel,'ParentModel',model,'ParamName',varParams{k});
                    ctrlVarsParamUsageMap(varCtrls.at(v))=[ctrlVarsParamUsageMap(varCtrls.at(v)),BlockPaths];
                end
            end
            usagesOfVarCtrl=ctrlVarsParamUsageMap(varCtrls.at(v));
            [~,idxs]=unique(arrayfun(@(usage)([usage.RootModelPath,'_',usage.ParamName]),usagesOfVarCtrl,'UniformOutput',false));
            usagesOfVarCtrl=usagesOfVarCtrl(idxs);
            ctrlVarsParamUsageMap(varCtrls.at(v))=usagesOfVarCtrl;
        end
    end
    ctrlVars=unique([ctrlVarsBlockUsageMap.keys,ctrlVarsParamUsageMap.keys]);
end