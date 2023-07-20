function restoreCoverageEnable(modelH)






    try




        observersSupported=SlCov.CoverageAPI.supportObserverCoverage();
        if(~observersSupported&&cvi.TopModelCov.isTopMostModel(modelH))||...
            (observersSupported&&(...
            (strcmp(get_param(modelH,'isObserverBD'),'on'))||...
            (cvi.TopModelCov.isTopMostModel(modelH)&&~hasObserverRefs(modelH))))

            coveng=cvi.TopModelCov.getInstance(modelH);
            if~isempty(coveng)&&~isempty(coveng.covModelRefData)
                coveng.covModelRefData.restoreCoverageEnable();
            end
        end

    catch MEx
        rethrow(MEx);
    end
end

function res=hasObserverRefs(modelH)


    observers=find_system(modelH,'FirstResultOnly',true,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','ObserverReference');
    res=~isempty(observers);
end

