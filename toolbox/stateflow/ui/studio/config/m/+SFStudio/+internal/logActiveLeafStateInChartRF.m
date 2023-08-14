function schema=logActiveLeafStateInChartRF(source,cbinfo)
    if strcmp(source,'SF')
        blockType='chart';
    else
        blockType='chartblock';

    end
    if isempty(cbinfo.getSelection())&&strcmp('chartblock',blockType)
        schema=sl_action_schema;
        schema.state='Disabled';
    else
        schema=Simulink.sdi.internal.SignalObserverMenu.getSchemaForStateActivity(cbinfo,blockType,'LeafActivity',[]);
    end
    schema.icon='logActiveLeafState';
    schema.label='stateflow_ui:studio:resources:logActiveLeafStateLabel';