function exprHandle=logicalConst(value)
    import sltest.expressions.*
    exprHandle=ExprHandle.makeMoveFrom(mi.logicalConst(value));
end
