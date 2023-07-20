function exportR16bToR16a(transformer)





    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.SwRecordLayout','SwRecordLayoutGroup');
    transformer.renameAttribute('packagedElement','Simulink.metamodel.arplatform.component.AtomicComponent','ParameterReceiverPorts','paramRPort');
    transformer.renameAttribute('packagedElement','Simulink.metamodel.arplatform.component.ParameterComponent','ParameterSenderPorts','paramPPort');
end


