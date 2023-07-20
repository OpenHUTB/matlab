



classdef CombinedActiveLogicErrorDetection<SldvExternalEngine
    methods
        function eng=CombinedActiveLogicErrorDetection
            eng.Name='CombinedActiveLogicErrorDetection';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
                eng.ExternalKillCommand='kill-rte-kernel';
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
                eng.ExternalKillCommand='cmd.exe /c kill-rte-kernel.bat';
            end
            eng.CommandArguments={'-a','combined_al_rte'};
            eng.UsesDVO=true;
        end
    end
end
