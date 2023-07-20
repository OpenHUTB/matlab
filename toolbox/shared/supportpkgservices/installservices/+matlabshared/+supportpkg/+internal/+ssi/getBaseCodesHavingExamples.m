function filteredBaseCodes=getBaseCodesHavingExamples(baseCodeArray,spRoot)











    baseCodeArray=cellstr(string(baseCodeArray));
    assert(iscellstr(baseCodeArray),'Expected baseCodeArray to be a cell array of strings');
    validateattributes(spRoot,{'char'},{'nonempty'},'addInstalledDirsToPath','spRoot',1);
    assert(logical(exist(spRoot,'dir')),sprintf('spRoot directory: %s does not exist',spRoot));

    filteredBaseCodes={};
    for i=1:length(baseCodeArray)
        currentBaseCode=baseCodeArray{i};
        openExamplesFcn=matlabshared.supportpkg.internal.ssi.util.getExamplesFcnAndArgsForBaseCode(currentBaseCode,spRoot);
        if~isempty(openExamplesFcn)

            filteredBaseCodes{end+1}=currentBaseCode;%#ok<AGROW>
        end
    end
end
