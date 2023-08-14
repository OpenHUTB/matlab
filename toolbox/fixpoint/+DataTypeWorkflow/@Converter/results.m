function out=results(this,runName,returnFunc)




















    if(nargin<3)
        returnFunc=@(~)true;
    end

    this.assertDEValid();

    this.loadSystems();

    this.validateRunName(runName);

    p=inputParser;
    p.addRequired('returnFunc',@(x)validateattributes(x,{'function_handle'},{'nonempty'}));
    try
        p.parse(returnFunc);
    catch invalid_type_exception
        error(message('SimulinkFixedPoint:autoscaling:invalidType',invalid_type_exception.message));
    end

    results=this.getAllResultsForRun(runName);
    out=[];
    for i=1:length(results)


        if isa(results(i),'fxptds.MATLABVariableResult')&&(~results(i).hasValidRootFunctionIDs||~results(i).isResultValid)
            results(i).getRunObject.clearResultFromRun(results(i));
            continue;
        end
        if~results(i).hasInterestingInformation

            continue;
        end
        result=DataTypeWorkflow.Result(results(i));
        returnValue=returnFunc(result);


        try
            returnValue=logical(returnValue);
        catch e
            error(message('SimulinkFixedPoint:autoscaling:FunctionShouldReturnLogical',class(returnValue)));
        end
        if(returnValue)
            if(isempty(out))
                out=result;
            else
                out(end+1)=result;%#ok<AGROW>
            end
        end
    end
end