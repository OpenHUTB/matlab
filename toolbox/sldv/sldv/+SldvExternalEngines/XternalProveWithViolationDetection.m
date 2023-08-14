




classdef XternalProveWithViolationDetection<SldvExternalEngine
    methods
        function eng=XternalProveWithViolationDetection
            eng.Name='(Experimental) Prove With Violation Detection';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','proveWithViolationDetection'};
            eng.UsesDVO=true;
        end
    end
end
