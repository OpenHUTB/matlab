function schema=simulationRecord(cbinfo)



    schema=sl_toggle_schema;
    schema.tag='Simulink:SimulationRecord';
    schema.refreshCategories={'SimulinkEvent:Simulation','interval#4'};
    schema.autoDisableWhen='Busy';
    schema.callback=@simulationRecordCB;


    schema.label=DAStudio.message('SDI:sdi:SLMenuRecordOn');
    schema.icon=schema.tag;


    inspectLogs=SLStudio.Utils.getConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','off');
    if strcmpi(inspectLogs,'on')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end


    schema.state='Hidden';
end


function simulationRecordCB(cbinfo)
    current=SLStudio.Utils.getConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','off');
    if strcmpi(current,'on')
        SLStudio.Utils.setConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','off');
    else
        SLStudio.Utils.setConfigSetParam(cbinfo.model.Handle,'InspectSignalLogs','on');
    end
end
