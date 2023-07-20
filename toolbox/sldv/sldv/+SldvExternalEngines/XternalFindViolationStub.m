




classdef XternalFindViolationStub<SldvExternalEngine
    methods
        function eng=XternalFindViolationStub
            eng.Name='Find Violation with Stubbing';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','findViolationStub','-depth','$STEP_MAX$'};
            eng.UsesDVO=true;
        end
    end
end
