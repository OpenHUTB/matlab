function useHalf=useHalfAsStorageType(interfaceTypes)






    useHalf=FunctionApproximation.internal.isHalfFeatureAvailable();
    useHalf=useHalf&&all(arrayfun(@(x)fixed.internal.type.isAnyFloat(x),interfaceTypes));
end