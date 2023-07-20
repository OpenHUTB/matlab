




classdef NonLinExtCombined<SldvExternalEngine
    methods
        function eng=NonLinExtCombined
            eng.Name='CombinedObjectives (Nonlinear Extended)';
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
