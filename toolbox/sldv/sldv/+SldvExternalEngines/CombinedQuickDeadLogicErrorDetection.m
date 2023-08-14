



classdef CombinedQuickDeadLogicErrorDetection<SldvExternalEngine
    methods
        function eng=CombinedQuickDeadLogicErrorDetection
            eng.Name='CombinedQuickDeadLogicErrorDetection';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
                eng.ExternalKillCommand='kill-rte-kernel';
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
                eng.ExternalKillCommand='cmd.exe /c kill-rte-kernel.bat';
            end
            eng.CommandArguments={'-a','combined_qdl_rte'};
            eng.UsesDVO=true;
        end
    end
end
