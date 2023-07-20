function schema=logActiveLeafStateInStateRF(~,cbinfo)
    schema=Simulink.sdi.internal.SignalObserverMenu.getSchemaForStateActivity(cbinfo,'state','LeafActivity',[]);
    schema.icon='logLeafStates';
    schema.label='stateflow_ui:studio:resources:leafStateActivity';
    if any(strcmp(cbinfo.Context.TypeChain,'stateTransitionTableAutoChartContext'))
        schema.state='Disabled';
    end
end