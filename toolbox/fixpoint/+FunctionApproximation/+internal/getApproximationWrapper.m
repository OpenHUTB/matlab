function approximationWrapper=getApproximationWrapper(options,data)




    if options.ApproximateSolutionType==FunctionApproximation.internal.ApproximateSolutionType.Simulink
        approximationWrapper=FunctionApproximation.internal.functionwrapper.BlockWrapper(data);
    else
        approximationWrapper=FunctionApproximation.internal.functionwrapper.MatlabScriptWrapper(data);
    end
end
