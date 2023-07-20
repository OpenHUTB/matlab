function exportR15bToR15a(transformer)






    transformer.renameAttribute('packagedElement','Simulink.metamodel.types.Enumeration','DefaultValue','GroundValue');


    transformer.setAttributeValue('Arguments','Direction','Error','Out');

    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.DataConstr','PrimitiveType');

    transformer.renameAttribute('packagedElement','Simulink.metamodel.arplatform.common.Package','ReferenceBase','referenceBase');

    transformer.skipAttribute('ReferenceBase','Simulink.metamodel.arplatform.common.ReferenceBase','BaseIsThisPackage');
    transformer.renameAttribute('ReferenceBase','Simulink.metamodel.arplatform.common.ReferenceBase','ShortLabel','shortLabel');
    transformer.renameAttribute('ReferenceBase','Simulink.metamodel.arplatform.common.ReferenceBase','Package','package');


    transformer.skipAttribute('ArTypedPIM','Simulink.metamodel.arplatform.interface.VariableData','DisplayFormat');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.FlowData','DisplayFormat');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Boolean','SwBaseType');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','SwBaseType');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.FixedPoint','SwBaseType');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.FloatingPoint','SwBaseType');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Integer','SwBaseType');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Boolean','CompuMethod');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','CompuMethod');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.FixedPoint','CompuMethod');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.FloatingPoint','CompuMethod');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Integer','CompuMethod');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Boolean','IsApplication');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','IsApplication');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.FixedPoint','IsApplication');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.FloatingPoint','IsApplication');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Integer','IsApplication');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Matrix','IsApplication');

    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','minValue');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','maxValue');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','isMinOpen');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','isMaxOpen');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','Length');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','IsSigned');


    transformer.skipAttribute('comSpec','Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec','UsesEndToEndProtection');
    transformer.skipAttribute('comSpec','Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec','UsesEndToEndProtection');


    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.FlowData','InvalidationPolicy');

end


