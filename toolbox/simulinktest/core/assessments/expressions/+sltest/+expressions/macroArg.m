function exprHandle=macroArg(value)
    import sltest.expressions.*
    exprHandle=ExprHandle.makeMoveFrom(mi.macroArg(value));
end
