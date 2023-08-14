





classdef ProverTCG<SldvExternalEngine
    methods
        function eng=ProverTCG
            eng.Name='ProverTCG';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','prover_tcg'};
            eng.AcceptExternalResults=true;
            eng.UsesDVO=true;
        end
    end
end
