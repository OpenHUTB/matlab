function[result,success]=eval_string_with_workspace_resolution(varargin)




    p=parseArguments(varargin{:});

    expression=p.Results.expression;
    model=p.Results.model;
    buildData=p.Results.buildData;

    result=[];
    success=false;

    if~Simulink.isRaccelDeployed
        [result,success]=slResolve(expression,model);
    end

    if~success
        try
            result=buildData.expressionEvaluator.evaluate(expression);
            success=true;
        catch
            result=[];
            success=false;
        end
    end

    if success
        result=processEvalResult(result);
    end

end



function result=processEvalResult(result)
    if isa(result,'Simulink.Parameter')
        result=result.Value;
    end
end



function p=parseArguments(varargin)
    p=inputParser;

    expressionArgName='expression';
    expressionValidation=@(x)validateattributes(x,{'char','string'},{'scalartext'});
    addRequired(p,expressionArgName,expressionValidation);

    modelArgName='model';
    modelValidation=@(x)validateattributes(x,{'char','string'},{'scalartext','nonempty'});
    addRequired(p,modelArgName,modelValidation);

    buildDataArgName='buildData';
    addRequired(p,buildDataArgName);

    parse(p,varargin{:});
end
