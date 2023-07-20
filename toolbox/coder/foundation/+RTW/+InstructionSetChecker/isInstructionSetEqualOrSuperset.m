function[isSuperset,unfoundRhs]=isInstructionSetEqualOrSuperset(lhsInstructions,rhsInstructions)

    [isSuperset,unfoundRhs]=...
    RTW.InstructionSetChecker.isInstructionSetEqualOrSubset(rhsInstructions,lhsInstructions);
end