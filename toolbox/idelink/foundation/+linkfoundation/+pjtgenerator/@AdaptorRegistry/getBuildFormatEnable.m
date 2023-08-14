function enable=getBuildFormatEnable(reg,AdaptorName)




    adaptorInfo=reg.getAdaptorInfo(AdaptorName);
    if isfield(adaptorInfo.Features,'BuildFormatWidgetEnable')
        enable=adaptorInfo.Features.BuildFormatWidgetEnable;
    else
        enable=true;
    end

end