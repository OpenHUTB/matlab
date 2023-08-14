function updatablePkgsByType=getSpPkgUpdateData(supportPackageType)











    validTypes={'hardware','software'};
    validatestring(supportPackageType,validTypes);



    allUpdatablePkgInfo=matlabshared.supportpkg.checkForUpdate('ReturnBaseCodes',true);


    updatablePkgsByType=[];
    for i=1:numel(allUpdatablePkgInfo)
        pluginData=matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(allUpdatablePkgInfo(i).BaseCode);
        if isempty(pluginData)
            continue;
        end
        if strcmp(pluginData.SupportCategory,supportPackageType)
            updatablePkgsByType=[updatablePkgsByType;allUpdatablePkgInfo(i)];%#ok<AGROW>
        end
    end
end