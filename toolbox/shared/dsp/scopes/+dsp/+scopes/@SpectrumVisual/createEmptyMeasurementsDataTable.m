function measurementsData=createEmptyMeasurementsDataTable(obj,~)




    if obj.IsSystemObjectSource
        measurementsData=table({[]},{[]},{[]},{[]},{[]},'VariableNames',...
        obj.MeasurementsDataFieldNames);
    else

        measurementsData=table({[]},{[]},{[]},{[]},{[]},{[]},'VariableNames',...
        obj.MeasurementsDataFieldNames);
    end
end