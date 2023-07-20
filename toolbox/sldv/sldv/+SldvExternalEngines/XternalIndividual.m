




classdef XternalIndividual<SldvExternalEngine
    methods
        function eng=XternalIndividual
            eng.Name='(Experimental) Individual';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','individual'};
            eng.UsesDVO=true;
            eng.AcceptExternalResults=true;
        end
    end
end
