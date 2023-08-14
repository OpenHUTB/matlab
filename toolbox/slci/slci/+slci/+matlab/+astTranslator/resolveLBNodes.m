




function resolveLBNodes(ast)

    if isa(ast,'slci.ast.SFAstEqualAssignment')

        children=ast.getChildren();
        assert(numel(children)>1);
        left=children{1};
        if isa(left,'slci.ast.SFAstConcatenateLB')
            newleft=slci.ast.SFAstMatlabFunctionCallOutput(...
            left.getMtree(),ast);
            children{1}=newleft;
            ast.setChildren(children);


            left.removeConstraints(cellfun(@getID,left.getConstraints,'UniformOutput',false));
        end

    end

    children=ast.getChildren();
    for k=1:numel(children)
        child=children{k};
        slci.matlab.astTranslator.resolveLBNodes(child);
    end

end
