function filteredBaseCodes=getBaseCodesHavingHwSetup(baseCodeArray)











    baseCodeArray=cell(baseCodeArray);
    assert(iscellstr(baseCodeArray),'Expected baseCodeArray to be a cell array of strings');

    filteredBaseCodes={};
    for i=1:length(baseCodeArray)
        currentBaseCode=baseCodeArray{i};

        spPkgInfo=matlabshared.supportpkg.internal.getSpPkgInfoForBaseCode(currentBaseCode);
        if isempty(spPkgInfo)
            continue;
        end
        if~isempty(spPkgInfo.FwUpdate)
            filteredBaseCodes{end+1}=currentBaseCode;%#ok<AGROW>
        end

    end
