




classdef XternalCombined<SldvExternalEngine
    methods
        function eng=XternalCombined
            eng.Name='(Experimental) Combined';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','combined'};
            eng.UsesDVO=true;
            eng.AcceptExternalResults=true;
        end
    end
end
