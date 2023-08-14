function associateRecords=gatherAssociatedParam(h,dataObjectWrapper)%#ok







    associateRecords.blkObj=dataObjectWrapper.Object;
    associateRecords.pathItem='1';
    associateRecords.ModelRequiredMax=[];
    associateRecords.ModelRequiredMin=[];


    value=...
    SimulinkFixedPoint.EntityAutoscalers.ParameterObjectEntityAutoscaler.resolveParameterObjectValue(...
    dataObjectWrapper.Object,dataObjectWrapper.Name,dataObjectWrapper.ContextName);

    if~isstruct(value)
        associateRecords.ModelRequiredMax=value;
        associateRecords.ModelRequiredMin=value;
    end
end