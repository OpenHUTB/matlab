function saveRegionSizeCallback(cbinfo)




    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');



    if(isempty(cbinfo.EventData)||isa(cbinfo.EventData,'double'))
        regionSize=ui.toolstripCtx.RegionSize;
    else
        regionSize=cbinfo.EventData;
    end

    threshold=str2double(regionSize);
    if isnan(threshold)||~isnumeric(threshold)||threshold<2||threshold>realmax
        ui.regionSize=2;
        DAStudio.error('sl_pir_cpp:creator:InvalidRegionOrCloneGroupSize');
    end

    ui.regionSize=threshold;

    ui.toolstripCtx.RegionSize=ui.regionSize;
end


