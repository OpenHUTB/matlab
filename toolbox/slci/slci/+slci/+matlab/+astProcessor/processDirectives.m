


function processDirectives(astObj)
    assert(isa(astObj,'slci.ast.SFAst'),...
    'Invalid input argument');
    if isa(astObj,'slci.ast.SFAstMatlabDirective')
        processDirective(astObj);
    end
    children=astObj.getChildren();
    for k=1:numel(children)
        child=children{k};
        slci.matlab.astProcessor.processDirectives(child);
    end
end


function processDirective(ast)
    if isa(ast,'slci.ast.SFAstInline')

        [~,parentFunc]=ast.getParentFuncAst;
        assert(isa(parentFunc,'slci.ast.SFAstMatlabFunctionDef'));
        parentFunc.setInline(ast.getArg());
    elseif isa(ast,'slci.ast.SFAstNullCopy')

        arg=ast.getArg();

        parent=ast.getParent();
        assert(isa(parent,'slci.ast.SFAstEqualAssignment'));
        opnds=parent.getChildren();
        assert(numel(opnds)==2);
        lhs=opnds{1};


        if isempty(lhs.getDataType())&&...
            ~isempty(arg.getDataType())
            lhs.setDataType(arg.getDataType());
        end

        if isequal(lhs.getDataDim(),-1)&&...
            ~isequal(arg.getDataDim(),-1)
            lhs.setDataDim(arg.getDataDim());
        end
    elseif isa(ast,'slci.ast.SFAstManualReview')

        [~,parentFunc]=ast.getParentFuncAst;
        assert(isa(parentFunc,'slci.ast.SFAstMatlabFunctionDef'));
        parentFunc.setManualReview(true);
    end
end
