function res=parseExpression(exprs,dataTypes,symbols,unresolved)

    if(nargin<3||isempty(symbols))
        symbols={};
    end
    if(nargin<4||isempty(unresolved))
        unresolved={};
    end
    assert(iscell(exprs));
    assert(iscell(dataTypes));
    assert(numel(exprs)==numel(dataTypes));
    res=cell(1,numel(exprs));
    for i=1:numel(exprs)
        v=sltest.assessments.internal.MatlabExpressionVisitor(exprs{i},'DataType',dataTypes{i},'Symbols',symbols,'UnresolvedSymbols',unresolved);
        r.Symbols=v.Symbols;
        r.BuiltinSymbols=v.BuiltinSymbols;
        r.ReservedSymbols=v.ReservedSymbols;
        r.Expr=v.Expr;
        r.FormattedExpr=v.ExprHighlight;
        r.HasError=v.hasError();
        res{i}=r;
    end

end
