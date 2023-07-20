function outputTypeString=getStringForOutputType(outputType)




    outputTypeString='';

    if outputType.isfixed
        outputTypeString=FunctionApproximation.internal.outputtypestring.StringForOutputTypeFixed.getStringForOutputType(outputType);
    elseif outputType.isfloat
        outputTypeString=FunctionApproximation.internal.outputtypestring.StringForOutputTypeFloat.getStringForOutputType(outputType);
    end
end