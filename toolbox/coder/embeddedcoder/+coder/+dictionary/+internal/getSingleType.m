function[out,varargout]=getSingleType(type)




    switch(type)
    case 'StorageClasses'
        out='StorageClass';
        varargout{1}=out;
    case{'FunctionCustomizationTemplates','FunctionClasses'}
        out='FunctionClass';
        varargout{1}='FunctionCustomizationTemplate';
    case 'MemorySections'
        out='MemorySection';
        varargout{1}=out;
    case 'RuntimeEnvironments'
        out='RuntimeEnvironment';
        varargout{1}=out;
    case 'TimerServices'
        out='Timer';
        varargout{1}=out;
    end
end
