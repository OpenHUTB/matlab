function importR16bFromR16a(transformer)



    transformer.renameAttribute('packagedElement','Simulink.metamodel.arplatform.component.AtomicComponent','paramRPort','ParameterReceiverPorts');
    transformer.renameAttribute('packagedElement','Simulink.metamodel.arplatform.component.ParameterComponent','paramPPort','ParameterSenderPorts');
end


