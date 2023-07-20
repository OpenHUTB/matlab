function exprHandle=expr(template,args)




    import sltest.expressions.*
    exprHandle=ExprHandle.makeMoveFrom(mi.expr(template,args));
end
