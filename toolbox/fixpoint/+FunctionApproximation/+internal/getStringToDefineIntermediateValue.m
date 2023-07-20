function intermediateValueString=getStringToDefineIntermediateValue(intermediateType)





    intermediateValueString='';



    if intermediateType.isdouble
        intermediateValueString=FunctionApproximation.internal.intermediatevaluestring.StringToDefineIntermediateValueForDouble.getIntermediateValueString(intermediateType);
    elseif intermediateType.issingle
        intermediateValueString=FunctionApproximation.internal.intermediatevaluestring.StringToDefineIntermediateValueForSingle.getIntermediateValueString(intermediateType);
    elseif intermediateType.isfixed
        intermediateValueString=FunctionApproximation.internal.intermediatevaluestring.StringToDefineIntermediateValueForFixed.getIntermediateValueString(intermediateType);
    end
end
