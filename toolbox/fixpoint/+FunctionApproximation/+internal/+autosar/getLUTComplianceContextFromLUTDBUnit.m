function context=getLUTComplianceContextFromLUTDBUnit(lutDBUnit)















    context=FunctionApproximation.internal.autosar.AUTOSARLUTComplianceContext();
    nInputs=lutDBUnit.SerializeableData.NumberOfDimensions;
    context.InputTypes=repmat(numerictype('single'),1,nInputs);
    for iType=1:nInputs
        context.InputTypes(iType)=numerictype(lutDBUnit.SerializeableData.InputTypes(iType));
    end
    context.OutputType=numerictype(lutDBUnit.SerializeableData.OutputType);
    context.Interpolation=FunctionApproximation.InterpolationMethod(lutDBUnit.SerializeableData.InterpolationMethod(1));
    context.StorageTypes=lutDBUnit.StorageTypes;
    context.BreakpointSpecification=lutDBUnit.BreakpointSpecification;
end