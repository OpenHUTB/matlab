function[adapters,defaultAdapter]=getAllAdapters()


    [adapters,defaultAdapter]=stm.internal.getRegisteredAdapters();
    for i=1:length(adapters)
        adapters{i}=str2func(adapters{i});
    end
    if(~isempty(defaultAdapter))
        defaultAdapter=str2func(defaultAdapter);
    else
        defaultAdapter=function_handle.empty;
    end
end
