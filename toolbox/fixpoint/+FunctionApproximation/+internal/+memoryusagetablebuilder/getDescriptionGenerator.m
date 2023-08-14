function descriptionGenerator=getDescriptionGenerator(isPathIsOfRegisteredType)




    if isPathIsOfRegisteredType

        descriptionGenerator=FunctionApproximation.internal.memoryusagetablebuilder.RegisteredBlockTableDescriptionGenerator();
    else

        descriptionGenerator=FunctionApproximation.internal.memoryusagetablebuilder.SystemNameTableDescriptionGenerator();
    end
end