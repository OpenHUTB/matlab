function newPrototype=setCodeFunctionName(oldPrototype,newFcnName)




    func=coder.mapping.internal.SimulinkFunctionMapping.getParsedFunction(oldPrototype);

    oldFcnName=regexprep(func.name,'\$','\\$');



    newPrototype=regexprep(oldPrototype,[oldFcnName,'(\s*\()'],...
    [newFcnName,'$1']);
end
