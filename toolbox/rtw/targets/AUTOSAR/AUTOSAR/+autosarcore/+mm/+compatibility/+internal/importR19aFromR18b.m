function importR19aFromR18b(transformer)





    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.SenderReceiverInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ModeSwitchInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ClientServerInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ParameterInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.NvDataInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.TriggerInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ServiceInterface','Ports');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ServiceInterface','IsService');
end


