

function out=getCoverageResults(out,simInputs)
    if isfield(simInputs,'CoverageSettings')
        if simInputs.CoverageSettings.CollectingCoverage
            runInfo=stm.internal.Coverage.populateRunInfo(simInputs);
            if~isempty(simInputs.HarnessName)
                simInputs.HarnessName=stm.internal.util.resolveHarness(simInputs.Model,simInputs.HarnessName);
            end
            coverageResults=stm.internal.Coverage.saveHelper(simInputs.Model,simInputs.HarnessName,runInfo);
            if~isempty(coverageResults)
                releaseName=regexprep(out.simulinkRelease,'[() ]','');
                [coverageResults.Release]=deal(releaseName);
                out.CoverageResults=coverageResults;
                evalin('base',"clear "+stm.internal.Coverage.CovSaveName);
            end
        end
    end
end
