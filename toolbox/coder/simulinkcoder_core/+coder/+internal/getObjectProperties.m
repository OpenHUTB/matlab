function[min,max,unit,desc]=getObjectProperties(modelName,objectName)

















    min='';
    max='';
    unit='';
    desc='';
    [varExists,dataObj]=coder.internal.evalObject(modelName,objectName);
    if varExists

        if isa(dataObj,'Simulink.DataObject')
            if~isempty(dataObj.Min)
                min=rtw.connectivity.CodeInfoUtils.double2str(dataObj.Min);
            end
            if~isempty(dataObj.Max)
                max=rtw.connectivity.CodeInfoUtils.double2str(dataObj.Max);
            end
            unit=dataObj.Unit;
            desc=dataObj.Description;
        elseif isa(dataObj,'Simulink.Breakpoint')
            if~isempty(dataObj.Breakpoints.Min)
                min=rtw.connectivity.CodeInfoUtils.double2str(dataObj.Breakpoints.Min);
            end
            if~isempty(dataObj.Breakpoints.Max)
                max=rtw.connectivity.CodeInfoUtils.double2str(dataObj.Breakpoints.Max);
            end
            unit=dataObj.Breakpoints.Unit;
            desc=dataObj.Breakpoints.Description;
        elseif isa(dataObj,'Simulink.LookupTable')
            if~isempty(dataObj.Table.Min)
                min=rtw.connectivity.CodeInfoUtils.double2str(dataObj.Table.Min);
            end
            if~isempty(dataObj.Table.Max)
                max=rtw.connectivity.CodeInfoUtils.double2str(dataObj.Table.Max);
            end
            unit=dataObj.Table.Unit;
            desc=dataObj.Table.Description;
        end
    end
end

