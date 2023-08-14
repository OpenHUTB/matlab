function code=generateCode(self)


    [symbolsInfo,conflicts]=self.parseSymbols();




    assessmentsCode={};
    symbols={};
    for assessmentInfo=self.assessmentsInfo
        try
            [asmt,syms]=self.compileAssessment(assessmentInfo);
            symbols=union(symbols,syms);
        catch ME
            asmt=comment(ME.getReport());
        end
        assessmentsCode{end+1}=asmt;%#ok<AGROW>
    end




    symbolsCode={};
    for symbol=symbols
        symbol=symbol{:};%#ok<FXSET>
        if ismember(symbol,conflicts)
            sym=comment(message('sltest:assessments:ConflictingSymbol',conflict).getString());
        else
            symbolInfo=symbolsInfo.(symbol);
            switch symbolInfo.scope
            case 'Expression'
                expr=symbolInfo.children.Expression;
                mt=mtree(expr);

                if~mt.root.iskind('PRINT')...
                    ||~mt.root.Next.isempty()...
                    ||~isempty(strtrim(expr(1:mt.root.Arg.lefttreepos-1)))...
                    ||~isempty(strtrim(expr(mt.root.Arg.righttreepos+1:end)))
                    sym=comment(message('sltest:assessments:InvalidExpressionForSymbol',expr,symbol).getString());
                else
                    sym=sprintf('%s%s = sltest.assessments.Signal(%s);',self.namespaces.symbols,symbol,expr);
                end

            otherwise
                sym=comment(message('sltest:assessments:NotExpressionSymbolsInCodeGen',symbol).getString());
            end
        end
        symbolsCode{end+1}=sym;%#ok<AGROW>
    end




    code=sprintf('%s\n\n\n%s',strjoin(symbolsCode,newline),strjoin(assessmentsCode,newline));
end

function str=comment(str)
    str=strcat('% ',strrep(str,newline,[newline,'% ']));
end
