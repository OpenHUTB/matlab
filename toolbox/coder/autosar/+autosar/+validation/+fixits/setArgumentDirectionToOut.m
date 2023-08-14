function setArgumentDirectionToOut(fcnPort,argumentName)




    m3iMethod=autosar.validation.AdaptiveMethodsValidator.getM3IMethodForFcnPort(fcnPort);
    m3iArgument=autosar.mm.Model.findElementInSequenceByName(m3iMethod.Arguments,argumentName);
    assert(~isempty(m3iArgument),'Could not find argument');
    trans=M3I.Transaction(m3iMethod.modelM3I);
    m3iArgument.Direction=Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out;
    trans.commit();
