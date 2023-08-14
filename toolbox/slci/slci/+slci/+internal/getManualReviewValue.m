




function value=getManualReviewValue(ast)
    assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));
    value=ast.getManualReview();
end