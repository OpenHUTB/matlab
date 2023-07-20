function memoryUnitOptions=getMemoryUnitOptions()






    memoryUnitOptions=arrayfun(@(x)char(x),enumeration('FunctionApproximation.internal.MemoryUnit'),'UniformOutput',false)';
end