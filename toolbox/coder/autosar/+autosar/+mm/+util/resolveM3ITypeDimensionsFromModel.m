function dims=resolveM3ITypeDimensionsFromModel(model,m3iType)






    function resolved=resolveSymbols(symbol)
        if existsInGlobalScope(model,symbol)
            resolved=num2str(evalinGlobalScope(model,[symbol,'.Value']));
        else
            resolved=symbol;
        end
    end

    if m3iType.SymbolicDimensions.size>0
        dims=ones(m3iType.SymbolicDimensions.size);
        for ii=1:m3iType.SymbolicDimensions.size
            parameterExpression=autosar.mm.util.extractSystemConstantExpressionFromM3I(...
            m3iType.SymbolicDimensions.at(ii));
            resolvedExpr=autosar.mm.util.transformFormulaExpression(...
            parameterExpression,@resolveSymbols);
            resolvedExpr=regexprep(resolvedExpr,'!','~');
            dims(ii)=eval(resolvedExpr);
        end
    else
        dims=ones(m3iType.Dimensions.size);
        for ii=1:m3iType.Dimensions.size
            dims(ii)=m3iType.Dimensions.at(ii);
        end
    end

end
