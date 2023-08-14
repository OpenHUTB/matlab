function[variantObjectNames,variantObjectUsageMap]=getVariantObjectsUsageInfo(modelName,varargin)











    variantObjectNames={};
    variantObjectUsageMap=containers.Map;

    if numel(varargin)>=1
        searchReferencedModels=varargin{1};
    else
        searchReferencedModels=true;
    end

    modelHandle=get_param(modelName,'Handle');
    warnState=warning('off');
    warnStateCleanup=onCleanup(@()warning(warnState));
    usageInfoForHierarchy=slvariants.internal.manager.core.getVariantControlUsageInfo(modelHandle,searchReferencedModels);
    warnStateCleanup=[];%#ok<NASGU>

    usageInfoPerModelMap=usageInfoForHierarchy.UsageInfo;

    modelNames=usageInfoPerModelMap.keys();
    for m=1:numel(modelNames)

        variantObjectNamesForModel=usageInfoPerModelMap.getByKey(modelNames{m}).varObjectInfo.keys();
        variantObjectNames=[variantObjectNames,variantObjectNamesForModel];%#ok<AGROW>

        if nargout>1
            for n=1:numel(variantObjectNamesForModel)
                blocksUsingVarObject=usageInfoPerModelMap.getByKey(...
                modelNames{m}).varObjectInfo.getByKey(variantObjectNamesForModel{n}).BlocksWithObject;
                numBlocksUsingVarObject=double(blocksUsingVarObject.Size);
                blocksUsingVarObjectCell=cell(1,numBlocksUsingVarObject);
                for b=1:numBlocksUsingVarObject
                    blocksUsingVarObjectCell{1,b}=blocksUsingVarObject.at(b).getBlockPathImpl();
                end
                if~variantObjectUsageMap.isKey(variantObjectNamesForModel{n})
                    variantObjectUsageMap(variantObjectNamesForModel{n})={};
                end
                variantObjectUsageMap(variantObjectNamesForModel{n})=[variantObjectUsageMap(variantObjectNamesForModel{n}),blocksUsingVarObjectCell];
            end
        end
    end
end