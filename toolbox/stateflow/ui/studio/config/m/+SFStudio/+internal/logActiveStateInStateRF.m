function schema=logActiveStateInStateRF(~,cbinfo)
    schema=Simulink.sdi.internal.SignalObserverMenu.getSchemaForStateActivity(cbinfo,'state','ChildActivity',[]);
    schema.icon='logChildStates';
    schema.label='stateflow_ui:studio:resources:childStateActivity';
    if any(strcmp(cbinfo.Context.TypeChain,'stateTransitionTableAutoChartContext'))
        schema.state='Disabled';
    end
end