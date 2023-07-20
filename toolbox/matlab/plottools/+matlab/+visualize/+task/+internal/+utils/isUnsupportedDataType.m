function isUnsupported=isUnsupportedDataType(dtVar)






    isUnsupported=false;
    try
        dtVal=matlab.visualize.task.internal.model.DataModel.getEvaluatedData(dtVar);
        isUnsupported=isa(dtVal,'struct')||isa(dtVal,'handle')||...
        isa(dtVal,'containers.Map')||...
        isa(dtVal,'timeseries');
    catch
    end