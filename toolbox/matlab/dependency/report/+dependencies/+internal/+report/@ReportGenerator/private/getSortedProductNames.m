function sortedNames=getSortedProductNames(node)




    finder=dependencies.internal.analysis.toolbox.ToolboxFinder;
    names=cellfun(...
    @(baseCode)string(finder.fromBaseCode(baseCode).Name),...
    node.Location);
    sortedNames=sort(names);
end
