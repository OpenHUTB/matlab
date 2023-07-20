function exportR14aToR13b(transformer)





    transformer.skipAttribute('Runnables','Simulink.metamodel.arplatform.behavior.Runnable','Events');


    transformer.skipAttribute('Behavior','Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior','ArTypedPIM');


    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.SenderReceiverInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ModeSwitchInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ClientServerInterface','Ports');
    transformer.skipAttribute('packagedElement','Simulink.metamodel.arplatform.interface.ParameterInterface','Ports');


    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.FlowData','SwCalibrationAccess');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.VariableData','SwCalibrationAccess');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.ParameterData','SwCalibrationAccess');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.ArgumentData','SwCalibrationAccess');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.IrvData','SwCalibrationAccess');
    transformer.skipAttribute('ModeGroup','Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement','SwCalibrationAccess');

    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.FlowData','SwAddrMethod');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.VariableData','SwAddrMethod');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.ParameterData','SwAddrMethod');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.ArgumentData','SwAddrMethod');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.IrvData','SwAddrMethod');

    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.FlowData','SwAlignment');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.VariableData','SwAlignment');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.ParameterData','SwAlignment');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.ArgumentData','SwAlignment');
    transformer.skipAttribute('DataElements','Simulink.metamodel.arplatform.interface.IrvData','SwAlignment');


    transformer.skipAttribute('ServiceDependency','Simulink.metamodel.arplatform.behavior.ServiceDependency','UsedDataElement');

end


