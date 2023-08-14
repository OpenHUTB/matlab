function[expressionModified,variantObjectNames]=replaceSimulinkVariantObjectsWithExpressions(model,expression,specialVarsForModelInfoManager,varargin)





    if nargin<4
        variablesNamesSoFar={};
    else
        variablesNamesSoFar=varargin{1};
    end

    if nargin<5
        replaceSlexprExpressions=false;
    else
        replaceSlexprExpressions=varargin{2};
    end

    variantObjectNames={};
    inputExpression=expression;
    variableNames=Simulink.variant.utils.getAllVariablesInExpresssion(expression);
    variableNamesToReplace={};variableValuesToReplace={};variablesNamesSoFarCurr={};
    for i=1:numel(variableNames)
        if any(strcmp(variableNames{i},variablesNamesSoFar))


            continue;
        end
        variablesNamesSoFarCurr=[variablesNamesSoFarCurr,variableNames{i}];%#ok<AGROW>
        if specialVarsForModelInfoManager.getIsSimulinkVariantObject(variableNames{i})
            variableNamesToReplace=[['\<',variableNames{i},'\>'],variableNamesToReplace];%#ok<AGROW>
            variableValuesToReplace=[variableValuesToReplace,['(',specialVarsForModelInfoManager.getConditionIfSimulinkVariant(variableNames{i}),')']];%#ok<AGROW>
            variantObjectNames=[variantObjectNames,variableNames{i}];%#ok<AGROW>
        end
        if replaceSlexprExpressions&&specialVarsForModelInfoManager.getIsExpValue(variableNames{i})



            variableNamesToReplace=[['\<',variableNames{i},'\>'],variableNamesToReplace];%#ok<AGROW>
            variableValuesToReplace=[variableValuesToReplace,['(',specialVarsForModelInfoManager.getExpressionIfExpValue(variableNames{i}),')']];%#ok<AGROW>
        end
    end
    expressionModified=regexprep(expression,variableNamesToReplace,variableValuesToReplace);
    if~strcmp(expressionModified,inputExpression)
        variablesNamesSoFar=[variablesNamesSoFar,variablesNamesSoFarCurr];
        [expressionModified,variantObjectNamesNested]=Simulink.variant.utils.replaceSimulinkVariantObjectsWithExpressions(model,expressionModified,specialVarsForModelInfoManager,variablesNamesSoFar,replaceSlexprExpressions);
        variantObjectNames=[variantObjectNames,variantObjectNamesNested];
    end
end


