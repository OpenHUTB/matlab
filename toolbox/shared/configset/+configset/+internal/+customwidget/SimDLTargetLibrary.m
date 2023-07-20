function out=SimDLTargetLibrary(cs,name)




    assert(strcmp(name,'SimDLTargetLibrary'));
    if strcmp(cs.getProp('GPUAcceleration'),'on')
        disp={message('RTW:configSet:DLTargetLibrary_CuDNN').getString,...
        message('RTW:configSet:DLTargetLibrary_TensorRT').getString};
        str={'cudnn','tensorrt'};
    else
        disp={message('RTW:configSet:DLTargetLibrary_MKLDNN').getString};
        str={'mkl-dnn'};
    end
    out=struct('str',str,'disp',disp);