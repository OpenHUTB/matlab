function code=compileTime(self,timeInfo,context)
    code='';

    if ischar(timeInfo)
        timeStr=strtrim(timeInfo);
    else
        assert(strcmp(timeInfo.dataType,'time'));
        timeStr=strtrim(timeInfo.label);
    end

    if isempty(timeStr)
        self.addError('sltest:assessments:EmptyTime',context,timeInfo.placeHolder);
    else
        exprVisitor=sltest.assessments.internal.MatlabExpressionVisitor(timeStr,'DataType','time','SymbolsNamespace',self.namespaces.timeSymbols,'ConvertScalarToConstant',false);
        matlabErrors=[];
        if~isempty(exprVisitor.SyntaxErrors)
            matlabErrors=[matlabErrors,exprVisitor.SyntaxErrors.msg];
        end
        if~isempty(exprVisitor.TypeErrors)
            matlabErrors=[matlabErrors,exprVisitor.TypeErrors.msg];
        end
        if~isempty(matlabErrors)
            ME=MException(message('sltest:assessments:InvalidTime',timeStr,context,timeInfo.placeHolder));
            for m=matlabErrors
                ME=ME.addCause(MException(m));
            end
            self.addError(ME);
        else
            code=exprVisitor.AssessmentsCode;
        end
        self.addTimeSymbols(exprVisitor.Symbols);
    end
end
