function fcn=getIDEBuildOptions(reg,AdaptorName)




    adaptorInfo=reg.getAdaptorInfo(AdaptorName);
    fcn=[];
    if isfield(adaptorInfo,'IDEBuildOptsFcn')
        fcn=adaptorInfo.IDEBuildOptsFcn;
    end

end

