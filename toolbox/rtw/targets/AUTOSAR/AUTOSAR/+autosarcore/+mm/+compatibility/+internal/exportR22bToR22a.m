function exportR22bToR22a(transformer)







    transformer.setAttributeValue('Arguments','Direction','CommunicationError|TimeoutError','Out');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ServiceInterface','MajorVersion');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ServiceInterface','MinorVersion');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.SwBaseType','NativeDeclaration');


    transformer.skipElement('ModuleInstantiation','Simulink.metamodel.arplatform.manifest.LogAndTraceInstantiation');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.manifest.Machine','LogAndTraceInstantiation');
    transformer.skipElement('packagedElement','Simulink.metamodel.arplatform.manifest.DltLogChannelToProcessMapping');
    transformer.skipElement('packagedElement','Simulink.metamodel.arplatform.manifest.FunctionGroupSet');

end


