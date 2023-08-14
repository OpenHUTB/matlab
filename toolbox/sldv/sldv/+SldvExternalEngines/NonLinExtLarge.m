




classdef NonLinExtLarge<SldvExternalEngine
    methods
        function eng=NonLinExtLarge
            eng.Name='LargeModel (Nonlinear Extended)';
            if isunix
                eng.CommandPath='';
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','largeNonLinear'};
            eng.AcceptExternalResults=true;
            eng.UsesDVO=true;
        end
    end
end
