function defaultBuildAction=getDefaultBuildAction(reg,AdaptorName,BuildFormat)




    adaptorInfo=reg.getAdaptorInfo(AdaptorName);

    buildActions=adaptorInfo.Features.BuildActions.(BuildFormat);

    defaultIdx=adaptorInfo.Features.DefaultBuildAction.(BuildFormat);

    defaultBuildAction=buildActions{defaultIdx};

end

