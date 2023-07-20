function context=getLUTComplianceContext(problemDefinition)















    context=FunctionApproximation.internal.autosar.AUTOSARLUTComplianceContext();
    context.InputTypes=problemDefinition.InputTypes;
    context.OutputType=problemDefinition.OutputType;
    context.Interpolation=problemDefinition.Options.Interpolation;
    context.StorageTypes=[context.InputTypes,context.OutputType];
    isAnyExplicitValues=any(arrayfun(@(x)~isEvenSpacing(x),problemDefinition.Options.BreakpointSpecification));
    if isAnyExplicitValues
        context.BreakpointSpecification="ExplicitValues";
    else
        context.BreakpointSpecification="EvenSpacing";
    end
end


