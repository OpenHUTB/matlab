



function computeSIDs(astObj)

    assert(isa(astObj,'slci.ast.SFAst'),...
    'Invalid input argument');

    astObj.computeSIDForMatlab();

    children=astObj.getChildren();
    for k=1:numel(children)
        child=children{k};
        slci.matlab.astProcessor.computeSIDs(child);
    end
end
