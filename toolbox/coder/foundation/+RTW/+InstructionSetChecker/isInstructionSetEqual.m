function[isEqual,unfoundLhs,unfoundRhs]=isInstructionSetEqual(lhsInstructions,rhsInstructions)


    [isEqualOrSub,unfoundLhs]=...
    RTW.InstructionSetChecker.isInstructionSetEqualOrSubset(lhsInstructions,rhsInstructions);
    [isEqualOrSuper,unfoundRhs]=...
    RTW.InstructionSetChecker.isInstructionSetEqualOrSuperset(lhsInstructions,rhsInstructions);
    isEqual=isEqualOrSub&&isEqualOrSuper;
    if isEqual
        assert(isempty(unfoundLhs)&&isempty(unfoundRhs));
    end
end