function y=getCustomPreprocessNames()


    prefStruct=getpref('SACustomFunctionList');
    functionsToAdd={};
    if~isempty(prefStruct)
        functionNames=fieldnames(prefStruct);
        for idx=1:numel(functionNames)
            functionsToAdd{idx}=prefStruct.(functionNames{idx});
        end
    end
    y=functionsToAdd;
end