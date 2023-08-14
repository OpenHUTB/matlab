function opts=getProfilingBuildOptions(reg,AdaptorName)





    adaptorInfo=reg.getAdaptorInfo(AdaptorName);


    opts=[];
    if isfield(adaptorInfo,'ProfilingBuildOptsFcn')
        fcn=adaptorInfo.ProfilingBuildOptsFcn;
        opts=fcn();
    end

end

