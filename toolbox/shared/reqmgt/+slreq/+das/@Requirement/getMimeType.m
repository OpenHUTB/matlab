function mimeType=getMimeType(studio)


    if(nargin>0&&~isempty(studio)&&studio.App.hasSpotlightView())
        mimeType=slreq.das.Requirement.mimeTypes('web');
    else
        mimeType=slreq.das.Requirement.mimeTypes('glue');
    end
end