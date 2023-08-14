function removeFimathString=getStringToRemoveFimath(outputType)





    removeFimathString='';

    if outputType.isfixed
        removeFimathString=FunctionApproximation.internal.removefimathstring.StringToRemoveFimathForFixedType.getStringToRemoveFimath;
    end
end