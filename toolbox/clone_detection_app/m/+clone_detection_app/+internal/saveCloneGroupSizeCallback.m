function saveCloneGroupSizeCallback(cbinfo)




    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');



    if(isempty(cbinfo.EventData)||isa(cbinfo.EventData,'double'))
        cloneGroupSize=ui.toolstripCtx.CloneGroupSize;
    else
        cloneGroupSize=cbinfo.EventData;
    end

    threshold=str2double(cloneGroupSize);
    if isnan(threshold)||~isnumeric(threshold)||threshold<2||threshold>realmax
        ui.cloneGroupSize=2;
        DAStudio.error('sl_pir_cpp:creator:InvalidRegionOrCloneGroupSize');
    end

    ui.cloneGroupSize=threshold;

    ui.toolstripCtx.CloneGroupSize=ui.cloneGroupSize;
end


