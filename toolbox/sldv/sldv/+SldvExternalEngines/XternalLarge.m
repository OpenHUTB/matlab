




classdef XternalLarge<SldvExternalEngine
    methods
        function eng=XternalLarge
            eng.Name='(Experimental) Large Model';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','large'};
            eng.UsesDVO=true;
            eng.AcceptExternalResults=true;
        end
    end
end
