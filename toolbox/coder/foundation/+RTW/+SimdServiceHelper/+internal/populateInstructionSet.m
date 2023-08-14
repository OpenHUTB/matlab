function populateInstructionSet(instructionSetName)
    simdService=RTW.SimdServiceHelper.internal.getSimdService(instructionSetName);
    instructionSet=target.internal.get('InstructionSet',instructionSetName);
    instructions=RTW.SimdServiceHelper.internal.getInstructionsFromService(simdService);
    instructionSet.Instructions=instructions;
end