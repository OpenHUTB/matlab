



function out=getCoverageResults(out,simWatcher,simInputs,varargin)
    simOut=[];
    if nargin==4
        simOut=varargin{1};
    end
    if~isempty(simWatcher.coverage)&&isfield(simInputs,'CoverageSettings')
        if simInputs.CoverageSettings.CollectingCoverage
            runInfo=stm.internal.Coverage.populateRunInfo(simInputs);
            coverageResults=stm.internal.Coverage.saveHelper(simWatcher.mainModel,simWatcher.harnessName,runInfo,simOut);
            if~isempty(coverageResults)
                releaseName=regexprep(out.simulinkRelease,'[() ]','');
                [coverageResults.Release]=deal(releaseName);
                out.CoverageResults=coverageResults;
                evalin('base',"clear "+stm.internal.Coverage.CovSaveName);
            end
        end
    end
end
