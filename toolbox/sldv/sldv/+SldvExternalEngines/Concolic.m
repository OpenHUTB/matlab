





classdef Concolic<SldvExternalEngine
    methods
        function eng=Concolic
            eng.Name='Concolic';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','concolic'};
            eng.AcceptExternalResults=true;
            eng.UsesDVO=true;
        end
    end
end
