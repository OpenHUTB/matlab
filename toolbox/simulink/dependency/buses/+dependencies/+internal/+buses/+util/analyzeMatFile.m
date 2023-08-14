function deps=analyzeMatFile(matFile,busNode,fileNode,baseType)





    vars=dependencies.internal.analysis.readVariables(matFile);
    names={vars.Name};
    types=[vars.Types];

    deps=dependencies.internal.buses.util.analyzeVariables(@varsOfTypeFcn,busNode,fileNode,baseType);

    function v=varsOfTypeFcn(type)
        match=strcmp(types,type);
        if any(match)
            v=load(matFile,names{match});
        else
            v=struct;
        end
    end

end
