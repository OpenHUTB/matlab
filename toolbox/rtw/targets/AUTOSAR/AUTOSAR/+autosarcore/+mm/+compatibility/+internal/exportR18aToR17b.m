function exportR18aToR17b(transformer)




    transformer.renameAttribute('comSpec','Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec','AliveTimeout','aliveTimeOut');
    transformer.renameAttribute('comSpec','Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec','HandleNeverReceived','handleNeverReceived');
    transformer.renameAttribute('comSpec','Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec','EnableUpdate','enableUpdate');
end


