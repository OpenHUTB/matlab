function[fracTypeStr,fractionStr]=getFractionStrings(fracType)



    fracTypeStr='';
    fractionStr='';




    if fracType.isdouble
        [fracTypeStr,fractionStr]=FunctionApproximation.internal.fractionstring.FractionStringsForDoubleOutput.getFractionStrings(fracType);
    elseif fracType.issingle
        [fracTypeStr,fractionStr]=FunctionApproximation.internal.fractionstring.FractionStringsForSingleOutput.getFractionStrings(fracType);
    elseif fracType.isfixed
        [fracTypeStr,fractionStr]=FunctionApproximation.internal.fractionstring.FractionStringsForFixedOutput.getFractionStrings(fracType);
    end
end
