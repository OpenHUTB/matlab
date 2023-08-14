




classdef XternalFindViolation<SldvExternalEngine
    methods
        function eng=XternalFindViolation
            eng.Name='(Experimental) Find Violation';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','findViolation','-depth','$STEP_MAX$'};
            eng.UsesDVO=true;
        end
    end
end
