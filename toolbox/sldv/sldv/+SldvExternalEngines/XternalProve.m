




classdef XternalProve<SldvExternalEngine
    methods
        function eng=XternalProve
            eng.Name='(Experimental) Prove';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','prove'};
            eng.UsesDVO=true;
        end
    end
end
