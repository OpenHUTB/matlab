function res=hasRuntimeParameters(parameterInfo)




    res=~(isempty(parameterInfo.logicals)&&...
    isempty(parameterInfo.integers)&&...
    isempty(parameterInfo.indices)&&...
    isempty(parameterInfo.reals));
end
