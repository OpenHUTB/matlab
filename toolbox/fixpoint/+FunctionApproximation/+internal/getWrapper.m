function functionWrapper=getWrapper(serializeableData,varargin)






    options=[];

    if nargin==2
        options=varargin{1};
    end

    if isa(serializeableData,'function_handle')

        functionWrapper=FunctionApproximation.internal.functionwrapper.FunctionHandleWrapper(serializeableData);

    elseif isa(serializeableData,'cfit')

        functionWrapper=FunctionApproximation.internal.functionwrapper.CurveFitHandleWrapper(serializeableData);

    elseif isa(serializeableData,'FunctionApproximation.internal.serializabledata.BlockData')

        functionWrapper=FunctionApproximation.internal.functionwrapper.BlockWrapper(serializeableData);

    elseif isa(serializeableData,'FunctionApproximation.internal.serializabledata.DirectLUData')

        functionWrapper=FunctionApproximation.internal.functionwrapper.BlockWrapper(serializeableData);

    elseif isa(serializeableData,'FunctionApproximation.internal.serializabledata.InterpNData')

        if isa(serializeableData,'FunctionApproximation.internal.serializabledata.LUTModelData')

            if FunctionApproximation.internal.useBlockWrapper(serializeableData,options)&&...
                (serializeableData.ApproximateType==FunctionApproximation.internal.ApproximateSolutionType.Simulink)

                functionWrapper=FunctionApproximation.internal.functionwrapper.BlockWrapper(serializeableData);

            elseif FunctionApproximation.internal.useScriptWrapper(serializeableData,options)&&...
                (serializeableData.ApproximateType==FunctionApproximation.internal.ApproximateSolutionType.MATLAB)

                functionWrapper=FunctionApproximation.internal.functionwrapper.MatlabScriptWrapper(serializeableData);

            else

                functionWrapper=FunctionApproximation.internal.functionwrapper.InterpNWrapper(serializeableData);

            end

        else

            functionWrapper=FunctionApproximation.internal.functionwrapper.InterpNWrapper(serializeableData);

        end

    end

end
