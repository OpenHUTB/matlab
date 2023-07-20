function ret=get_dl_params(blkHandle)




    modelH=bdroot(blkHandle);
    cs=getActiveConfigSet(modelH);
    ret=lower(get_param(cs,'DLTargetLibrary'));


    if strcmpi(ret,'mkl-dnn')
        ret='mkldnn';
    end
end
