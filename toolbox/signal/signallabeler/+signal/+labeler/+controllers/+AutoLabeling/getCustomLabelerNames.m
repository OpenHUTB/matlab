function y=getCustomLabelerNames()


    prefStruct=getpref('LACustomLabelerFunctionList');

    if~isempty(prefStruct)
        functionNames=fieldnames(prefStruct);
        functionsToAdd=cell(numel(functionNames),1);
        for idx=1:numel(functionNames)
            functionsToAdd{idx}=prefStruct.(functionNames{idx});
        end
    else
        functionsToAdd=cell(0,1);
    end
    y=functionsToAdd;
end