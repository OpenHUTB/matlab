function nt=getFloatingPointNumericType(DTString)










    if SimulinkFixedPoint.DataTypeContainer.isStringBuiltInFloat(DTString)
        nt=fixdt(DTString);
    else
        nt=eval(DTString);
    end
end


