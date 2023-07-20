function saveMAReportData(obj,value)
    PerfTools.Tracer.logMATLABData('MAGroup','Save MA Report Data',true);
    [~,ObjectIndex]=obj.loadData('allrptinfo','Index',value.Index);
    if isempty(ObjectIndex)
        obj.saveData('allrptinfo',value);
    else
        obj.modifyData(ObjectIndex(end),value);
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Save MA Report Data',false);
end
