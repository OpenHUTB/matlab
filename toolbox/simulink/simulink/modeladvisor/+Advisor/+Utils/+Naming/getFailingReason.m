function reason=getFailingReason(prefix,name,failRegExp,convention)
    if strcmpi(convention,'MAAB')
        splitExpr=split(failRegExp,'|');
        indiv=regexp(name,splitExpr);
        reason={};

        for i=1:length(splitExpr)
            if~isempty(indiv{i})
                switch splitExpr{i}
                case '(^.{32,}$)'
                    reason{end+1}=Advisor.Utils.Naming.getDASText(prefix,'_Issue_Length');%#ok<*AGROW>
                case '([^a-zA-Z_0-9])'
                    reason{end+1}=Advisor.Utils.Naming.getDASText(prefix,'_Issue_CharactersNotAllowed');%#ok<*AGROW>
                case '(^\d)'
                    reason{end+1}=Advisor.Utils.Naming.getDASText(prefix,'_Issue_StartsWithNumber');%#ok<*AGROW>
                case '(^ )'
                    reason{end+1}=Advisor.Utils.Naming.getDASText(prefix,'_Issue_StartsWithSpace');%#ok<*AGROW>
                case '(__)'
                    reason{end+1}=Advisor.Utils.Naming.getDASText(prefix,'_Issue_ConsecutiveUnderscores');%#ok<*AGROW>
                case{'(^_)','(_$)'}
                    reason{end+1}=Advisor.Utils.Naming.getDASText(prefix,'_Issue_Underscores');%#ok<*AGROW>
                otherwise
                    reason{end+1}=Advisor.Utils.Naming.getDASText(prefix,'_Reason_Default');%#ok<*AGROW>
                end
            end
        end
        if~isempty(reason)
            reason=strjoin(unique(reason),', ');
        end
    else

        reason=Advisor.Utils.Naming.getDASText(prefix,'_Issue_CustomRegex');
    end

end