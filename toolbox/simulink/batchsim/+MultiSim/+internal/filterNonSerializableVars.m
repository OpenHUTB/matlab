function vars=filterNonSerializableVars(inVars)





    varList=fieldnames(inVars);

    shouldNotStoreInWorkspaceFcn=@(x)isa(x,'Composite')||...
    isa(x,'parallel.internal.customattr.CustomPropTypes')||...
    isa(x,'distributed');

    storeInWorkspace=~cellfun(@(x)shouldNotStoreInWorkspaceFcn(inVars.(x)),varList);
    if all(storeInWorkspace)

        vars=inVars;
    else

        varNames=varList(storeInWorkspace);
        varValues=cellfun(@(f)inVars.(f),varNames,'UniformOutput',false);
        vars=cell2struct(varValues,varNames);
    end
end