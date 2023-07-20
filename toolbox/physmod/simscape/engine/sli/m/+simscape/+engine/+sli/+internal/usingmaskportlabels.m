function result=usingmaskportlabels()




    persistent MASKLABELS;

    if isempty(MASKLABELS)
        MASKLABELS=strcmp(DVG.DevTool.getSetting('PMDVGLabel'),'off');
    end

    result=MASKLABELS;

end
