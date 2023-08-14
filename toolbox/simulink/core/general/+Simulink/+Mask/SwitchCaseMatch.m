

function booleanResult=SwitchCaseMatch(obj,switchExpression,caseExpression)
    switchExpression=obj.EvalExpression(switchExpression);
    caseExpression=obj.EvalExpression(caseExpression);
    switchExpression=switchExpression{1};
    caseExpression=caseExpression{1};
    if(isnumeric(caseExpression))
        booleanResult=(switchExpression==caseExpression);
    elseif(isstring(caseExpression)||ischar(caseExpression))
        booleanResult=strcmp(switchExpression,caseExpression);
    elseif(iscell(caseExpression))






        fCompare=@(x)(x==switchExpression);
        if(ischar(switchExpression)||isstring(switchExpression))
            fCompare=@(x)strcmp(x,switchExpression);
        end
        booleanResult=any(all(cellfun(@(x)fCompare(x),caseExpression)));
    end
end