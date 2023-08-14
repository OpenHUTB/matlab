function defaultBuildAction=getDefaultBuildFormat(reg,AdaptorName)




    adaptorInfo=reg.getAdaptorInfo(AdaptorName);


    if isfield(adaptorInfo.Features,'DefaultBuildFormat')
        defaultIdx=adaptorInfo.Features.DefaultBuildFormat;
    else
        defaultIdx=1;
    end


    buildFormats={'Project','Makefile'};
    defaultBuildAction=buildFormats{defaultIdx};

end