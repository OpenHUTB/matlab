function exportR14bToR14a(transformer)





    transformer.skipAttribute('ConstantValue','Simulink.metamodel.types.EnumerationLiteralReference','LiteralText');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Boolean','DataConstr');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Enumeration','DataConstr');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.FixedPoint','DataConstr');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.FloatingPoint','DataConstr');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Integer','DataConstr');


    transformer.skipAttribute('comSpec','Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec','InitValue');
    transformer.skipAttribute('comSpec','Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec','InitValue');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Boolean','minValue');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Boolean','maxValue');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.types.Unit','ConvFactor');

end
