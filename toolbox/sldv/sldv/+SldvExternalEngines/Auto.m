




classdef Auto<SldvExternalEngine
    methods
        function eng=Auto
            eng.Name='Auto';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','combinedNonLinear'};
            eng.AcceptExternalResults=true;
            eng.UsesDVO=true;
        end
    end
end
