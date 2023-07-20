function schema=logActiveStateSelf(~,cbinfo)
    schema=Simulink.sdi.internal.SignalObserverMenu.getSchemaForStateActivity(cbinfo,'state','SelfActivity',[]);
    schema.icon='logState';
    schema.label='stateflow_ui:studio:resources:logSelectedState';
    if any(strcmp(cbinfo.Context.TypeChain,'stateTransitionTableAutoChartContext'))
        schema.state='Disabled';
    end
end