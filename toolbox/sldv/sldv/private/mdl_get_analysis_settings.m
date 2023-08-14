function[strategy,searchDepth,timeLimit]=mdl_get_analysis_settings(testcomp)



    mode=testcomp.activeSettings.Mode;
    timeLimit=testcomp.activeSettings.MaxProcessTime;

    strategy=99;

    if strcmp(mode,'TestGeneration')
        searchDepth=testcomp.activeSettings.MaxTestCaseSteps;
    elseif strcmp(mode,'DesignErrorDetection')
        searchDepth=20;
    elseif strcmp(mode,'PropertyProving')
        searchDepth=testcomp.activeSettings.MaxViolationSteps;
    end
end
