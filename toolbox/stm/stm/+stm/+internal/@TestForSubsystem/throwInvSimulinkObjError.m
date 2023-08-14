function throwInvSimulinkObjError(invalidInds)




    eID="stm:general:NotAValidSubsystemObject";
    baseMex=MException(eID,message(eID).getString);
    offendingIndices=strjoin(string(find(invalidInds)),", ");
    eID="stm:TestForSubsystem:InvSimulinkObjectsInComponentInput";
    causeMex=MException(eID,message(eID,offendingIndices).getString);
    baseMex=baseMex.addCause(causeMex);
    throw(baseMex);
end
