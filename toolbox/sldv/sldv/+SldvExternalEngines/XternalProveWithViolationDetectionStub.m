




classdef XternalProveWithViolationDetectionStub<SldvExternalEngine
    methods
        function eng=XternalProveWithViolationDetectionStub
            eng.Name='Prove with Violation Detection and Stubbing';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','proveWithViolationDetectionStub'};
            if~slavteng('feature','AnalysisLevelsStrategy')
                eng.CommandArguments(end+1)={'-depth'};
                eng.CommandArguments(end+1)={'$STEP_MAX$'};
            end
            eng.UsesDVO=true;
        end
    end
end
