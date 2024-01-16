function openExamplesForBaseCodes(baseCodeArray,spRoot)
    baseCodeArray=cellstr(string(baseCodeArray));
    assert(iscellstr(baseCodeArray),'Expected baseCodeArray to be a cell array of strings');
    validateattributes(spRoot,{'char'},{'nonempty'},'addInstalledDirsToPath','spRoot',1);
    assert(logical(exist(spRoot,'dir')),sprintf('spRoot directory: %s does not exist',spRoot));

    for i=1:length(baseCodeArray)
        currentBaseCode=baseCodeArray{i};
        openExamplesFcn=matlabshared.supportpkg.internal.ssi.util.getExamplesFcnAndArgsForBaseCode(currentBaseCode,spRoot);

        if~isempty(openExamplesFcn)
            openExamplesFcn();
        end
    end

end
