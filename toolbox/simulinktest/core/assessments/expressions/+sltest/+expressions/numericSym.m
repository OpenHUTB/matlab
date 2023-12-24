function exprHandle=numericSym(value)
    import sltest.expressions.*
    exprHandle=ExprHandle.makeMoveFrom(mi.numericSym(value));
end
