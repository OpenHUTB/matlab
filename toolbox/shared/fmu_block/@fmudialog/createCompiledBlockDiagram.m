function[bd]=createCompiledBlockDiagram(model)
    engineInterface=Simulink.CMI.CompiledSession(Simulink.EngineInterfaceVal.byFiat);
    bd=Simulink.CMI.CompiledBlockDiagram(engineInterface,model);
end
