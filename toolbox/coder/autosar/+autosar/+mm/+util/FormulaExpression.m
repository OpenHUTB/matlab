



classdef FormulaExpression<handle





    properties(Access=private)

        ContainsSymbolsFlag;



        NormalExpression;


        EvaluatedExpression;


        SymbolDefinitions;
    end

    methods(Access=public)
        function this=FormulaExpression(expr,symbolDefs)










            if 1<nargin
                this.SymbolDefinitions=symbolDefs;
            else
                this.SymbolDefinitions=containers.Map();
            end

            this.ContainsSymbolsFlag=[];
            this.NormalExpression=this.convertToNormalExpression(expr);
            this.EvaluatedExpression=[];
        end

        function normalExpr=convertToNormalExpression(~,expr)






            if ischar(expr)||isStringScalar(expr)
                normalExpr=expr;
            elseif isnumeric(expr)
                normalExpr=num2str(expr);
            else
                assert(false,'FormulaExpression class does not accept expressions of type %s.',class(expr));
            end
        end

        function ret=containsSymbols(this)


            if isempty(this.ContainsSymbolsFlag)
                this.ContainsSymbolsFlag=false;
                this.evaluated();
            end
            ret=this.ContainsSymbolsFlag;
        end

        function expr=expression(this)

            expr=this.NormalExpression;
        end

        function expr=evaluated(this)




            if isempty(this.EvaluatedExpression)
                resolvedExpr=autosar.mm.util.FormulaExpression.transformFormulaExpression(...
                this.expression,@this.resolveSymbol);
                try
                    this.EvaluatedExpression=eval(resolvedExpr);
                catch err
                    ex=MSLException([],message('autosarstandard:importer:UnableToEvaluateVariantExpression',this.expression));
                    throw(addCause(ex,err));
                end
            end
            expr=this.EvaluatedExpression;
        end
    end

    methods(Access=private)
        function resolved=resolveSymbol(this,symbol)






            if this.SymbolDefinitions.isKey(symbol)
                this.ContainsSymbolsFlag=true;
                value=this.SymbolDefinitions(symbol);
                if 1<numel(value)
                    resolved=num2str(value(1));
                else
                    resolved=num2str(value);
                end
            elseif~isnan(str2double(symbol))
                resolved=symbol;
            elseif any(strcmp(symbol,["true","false"]))
                resolved=symbol;
            else
                msgId='autosarstandard:common:missingSymbol';
                newException=MException(msgId,DAStudio.message(msgId,symbol,this.NormalExpression));
                throw(newException);
            end
        end
    end

    methods(Static,Access=public)
        function expr=arxmlToMStyle(expr)


            expr=regexprep(expr,'!','~');
        end

        function formulaExpression=createFromARXML(expression,systemConstantValues)













            if iscell(expression)
                mStyleExpr=cell(length(expression),1);
                for ii=1:length(expression)
                    expr=...
                    autosar.mm.util.extractSystemConstantExpressionFromM3I(expression{ii});
                    mStyleExpr{ii}=...
                    autosar.mm.util.FormulaExpression.arxmlToMStyle(expr);
                end
            else
                expr=...
                autosar.mm.util.extractSystemConstantExpressionFromM3I(expression);
                mStyleExpr=...
                autosar.mm.util.FormulaExpression.arxmlToMStyle(expr);
            end
            formulaExpression=autosar.mm.util.FormulaExpression(...
            mStyleExpr,systemConstantValues);
        end

        function expr=transformFormulaExpression(expression,transform)


















            [matchstart,matchend]=regexp(expression,'[\w]+');
            expr='';

            if(isempty(matchstart))
                expr=expression;
            else
                text_start=1;
                for ii=1:length(matchstart)
                    text_end=matchstart(ii)-1;
                    text=expression(text_start:text_end);
                    symbol=expression(matchstart(ii):matchend(ii));
                    symbol=transform(symbol);
                    expr=sprintf('%s%s%s',expr,text,symbol);
                    text_start=matchend(ii)+1;
                end
                text_end=length(expression);
                expr=sprintf('%s%s',expr,expression(text_start:text_end));
            end
        end
    end
end


