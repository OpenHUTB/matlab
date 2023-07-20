




classdef XternalLong<SldvExternalEngine
    methods
        function eng=XternalLong
            eng.Name='(Experimental) Long Test Cases';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','long'};
            eng.UsesDVO=true;
            eng.AcceptExternalResults=true;
        end
    end
end
