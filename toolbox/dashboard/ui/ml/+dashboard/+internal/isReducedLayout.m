function isReduced=isReducedLayout(rootFolder)




    currentSetting=dashboard.internal.getReducedLayoutState(rootFolder);


    if isempty(currentSetting)
        isReduced=false;
    else
        isReduced=currentSetting;
    end

end
