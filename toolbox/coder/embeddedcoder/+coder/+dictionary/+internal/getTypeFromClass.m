function out=getTypeFromClass(className)




    switch(className)
    case{'coderdictionary.data.StorageClass','coderdictionary.data.LegacyStorageClass'}
        out='StorageClass';
    case 'coderdictionary.data.FunctionClass'
        out='FunctionCustomizationTemplate';
    case{'coderdictionary.data.MemorySection','coderdictionary.data.LegacyMemorySection'}
        out='MemorySection';
    case 'coderdictionary.data.RuntimeEnvironment'
        out='RuntimeEnvironment';
    case 'coderdictionary.data.TimerService'
        out='TimerService';
    end
end


