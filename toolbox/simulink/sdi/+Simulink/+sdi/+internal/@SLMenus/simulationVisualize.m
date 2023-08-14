function schema=simulationVisualize(cbinfo)



    schema=sl_toggle_schema;
    schema.tag='Simulink:SimulationVisualize';
    schema.refreshCategories={'SimulinkEvent:Simulation','interval#4'};
    schema.autoDisableWhen='Busy';
    schema.callback=@simulationVisualizeCB;


    schema.label=DAStudio.message('SDI:sdi:SLMenuRecordOff');
    schema.icon='';


    inspectLogs=SLStudio.Utils.getConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','off');
    if strcmpi(inspectLogs,'off')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
end


function simulationVisualizeCB(cbinfo)
    current=SLStudio.Utils.getConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','off');
    if strcmpi(current,'on')
        SLStudio.Utils.setConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','off');
    else
        SLStudio.Utils.setConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','on');
    end
end
