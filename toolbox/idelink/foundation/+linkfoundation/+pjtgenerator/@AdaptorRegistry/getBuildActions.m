function buildActions=getBuildActions(reg,AdaptorName,BuildFormat)




    buildActions=reg.getAdaptorInfo(AdaptorName).Features.BuildActions.(BuildFormat);

end

