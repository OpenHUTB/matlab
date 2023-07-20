



function err=getInconsistentSlexprError(varNameSimParamExpressionMap,numConfigs,errid)



    err=[];
    varControlVarsParamExpression=varNameSimParamExpressionMap.keys;
    for j=1:numel(varControlVarsParamExpression)
        allExpressions=varNameSimParamExpressionMap(varControlVarsParamExpression{j});
        allUniqueExpressions=unique(allExpressions);
        if(numel(allUniqueExpressions)>1)||(numel(allExpressions)<numConfigs)
            err=MException(message(errid,varControlVarsParamExpression{j}));
            return;
        end
    end
end
