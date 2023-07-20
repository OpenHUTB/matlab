function[slHs,sfHs,sfFade,indirectHs]=getHandlesForHighlighting(modelH,filterSettings)


    if nargin<2
        filterSettings=rmi.settings_mgr('get','filterSettings');
    end




    if rmidata.isExternal(modelH)
        [slHs,sfHs,sfFade,indirectHs]=rmidata.getHandlesForHighlighting(modelH,filterSettings);
    else
        [slAllHs,sfAllHs,slFlags,sfFlags,indirectHs]=rmisl.getAllObjectsAndRmiFlags(modelH,filterSettings);
        slHs=slAllHs(slFlags);
        sfHs=sfAllHs(sfFlags);
        sfFade=sfAllHs(~sfFlags);
    end

end

