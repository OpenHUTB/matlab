




function processPersistents(ast)


    pArgs=ast.getPersistentArgs();
    for j=1:numel(pArgs)
        slci.matlab.astProcessor.computeSIDs(pArgs{j});
    end
end