function newVal=setArrayContainerType(this,val)
    if isempty(this)||isempty(this.getConfigSet)
        if slfeature('RTWCGStdArraySupport')
            newVal=val;
        else
            newVal='C-style array';
        end
    else
        if~strcmp(get_param(this.getConfigSet,'CodeInterfacePackaging'),'C++ class')&&...
            ~strcmp(val,'C-style array')
            DAStudio.error('RTW:configSet:ArrayContainerTypeNotSupported');
        end
        if strcmpi(get_param(this.getConfigSet,'GenerateGPUCode'),'CUDA')&&...
            ~strcmp(val,'C-style array')
            DAStudio.error('RTW:configSet:CannotSetParamGpuEnabled','ArrayContainerType');
        end
        newVal=val;
    end
end

