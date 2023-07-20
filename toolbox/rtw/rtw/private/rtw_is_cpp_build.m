function[isCPP,targetLangExt]=rtw_is_cpp_build(modelName)




    isCPP=strcmp(get_param(modelName,'TargetLang'),'C++');
    isGpuCodeGen=strcmp(get_param(modelName,'GenerateGPUCode'),'CUDA');

    if nargout>1
        if isCPP
            if isGpuCodeGen
                targetLangExt='cu';
            else
                targetLangExt='cpp';
            end
        else
            targetLangExt='c';
        end
    end

