function schema=logActiveStateInChartRF(source,cbinfo)
    if strcmp(source,'SF')
        blockType='chart';
    else
        blockType='chartblock';
    end
    if isempty(cbinfo.getSelection())&&strcmp('chartblock',blockType)
        schema=sl_action_schema;
        schema.state='Disabled';
    else
        schema=Simulink.sdi.internal.SignalObserverMenu.getSchemaForStateActivity(cbinfo,blockType,'ChildActivity',[]);
        schema.icon='logActiveState';
        schema.label='stateflow_ui:studio:resources:logActiveStateLabel';
    end