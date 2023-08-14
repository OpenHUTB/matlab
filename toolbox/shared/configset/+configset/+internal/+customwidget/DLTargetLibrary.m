function out=DLTargetLibrary(cs,name)




    assert(strcmp(name,'DLTargetLibrary'));
    if strcmp(cs.getProp('GenerateGPUCode'),'CUDA')
        disp={message('RTW:configSet:DLTargetLibrary_None').getString,...
        message('RTW:configSet:DLTargetLibrary_CuDNN').getString,...
        message('RTW:configSet:DLTargetLibrary_TensorRT').getString};
        str={'none','cudnn','tensorrt'};
    elseif strcmp(cs.getProp('GenerateGPUCode'),'None')
        if strcmp(cs.getProp('TargetLang'),'C++')
            disp={message('RTW:configSet:DLTargetLibrary_None').getString,...
            message('RTW:configSet:DLTargetLibrary_MKLDNN').getString,...
            message('RTW:configSet:DLTargetLibrary_ARMCompute').getString};
            str={'none','mkl-dnn','arm-compute'};
        else
            disp={message('RTW:configSet:DLTargetLibrary_None').getString};
            str={'none'};
        end
    end
    out=struct('str',str,'disp',disp);
