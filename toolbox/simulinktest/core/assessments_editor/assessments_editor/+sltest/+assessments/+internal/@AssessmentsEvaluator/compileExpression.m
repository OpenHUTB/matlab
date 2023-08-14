function code=compileExpression(self,exprInfo,context)
    code='';

    if ischar(exprInfo)
        exprStr=strtrim(exprInfo);
        exprType='logical';
    else
        assert(strcmp(exprInfo.type,'expression'));
        exprStr=strtrim(exprInfo.label);
        exprType=exprInfo.dataType;
    end

    if isempty(exprStr)
        self.addError('sltest:assessments:EmptyExpression',context,exprInfo.placeHolder);
    else
        exprVisitor=sltest.assessments.internal.MatlabExpressionVisitor(exprStr,'DataType',exprType,'Symbols',self.symbolList,'SymbolsNamespace',self.namespaces.symbols);

        matlabErrors=[];
        if~isempty(exprVisitor.SyntaxErrors)
            matlabErrors=[matlabErrors,exprVisitor.SyntaxErrors.msg];
        end
        if~isempty(exprVisitor.TypeErrors)
            matlabErrors=[matlabErrors,exprVisitor.TypeErrors.msg];
        end
        if~isempty(matlabErrors)
            ME=MException(message('sltest:assessments:InvalidExpression',exprStr,context,exprInfo.placeHolder));
            for m=matlabErrors
                ME=ME.addCause(MException(m));
            end
            self.addError(ME);
        end
        self.addSymbols(exprVisitor.Symbols);
        self.addReservedSymbols(exprVisitor.ReservedSymbols);
        code=exprVisitor.AssessmentsCode;
    end
end
