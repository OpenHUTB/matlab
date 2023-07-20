function saveParameterThreshold(cbinfo)




    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');



    if(isempty(cbinfo.EventData)||isa(cbinfo.EventData,'double'))
        paramThreshold=ui.toolstripCtx.parameterThreshold;
    else
        paramThreshold=cbinfo.EventData;
    end

    threshold=str2double(paramThreshold);
    if isnan(threshold)||threshold<0||threshold>realmax
        ui.parameterThreshold=ui.defaultThreshold;
        ui.toolstripCtx.parameterThreshold=ui.defaultThreshold;
        DAStudio.error('sl_pir_cpp:creator:IllegalNumber',num2str(realmax));
    end

    if isempty(paramThreshold)
        ui.parameterThreshold=ui.defaultThreshold;
        ui.toolstripCtx.parameterThreshold=ui.defaultThreshold;
    else
        ui.parameterThreshold=paramThreshold;
    end

    ui.toolstripCtx.parameterThreshold=ui.parameterThreshold;
end



