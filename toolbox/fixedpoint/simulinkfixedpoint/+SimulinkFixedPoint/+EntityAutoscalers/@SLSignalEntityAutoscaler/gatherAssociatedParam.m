function associateRecords=gatherAssociatedParam(h,dataObjectWrapper)%#ok






    associateRecords.blkObj=dataObjectWrapper;
    associateRecords.pathItem='1';

    associateRecords.ModelRequiredMin=[];
    associateRecords.ModelRequiredMax=[];

    if~isempty(dataObjectWrapper.Object.InitialValue)

        SDOinitalValue=slResolve(dataObjectWrapper.Object.InitialValue,...
        dataObjectWrapper.Context.getFullName);

        if isstruct(SDOinitalValue)
            return;
        end

        [associateRecords.ModelRequiredMin,associateRecords.ModelRequiredMax]=...
        SimulinkFixedPoint.extractMinMax(SDOinitalValue);

    end
end


