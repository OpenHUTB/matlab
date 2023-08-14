function nt=getSimulinkNumericType(numericType)





    nt=numericType;
    if isa(numericType,'embedded.numerictype')
        nt=SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer(fixdt(numericType),[]).evaluatedNumericType;
    end
end