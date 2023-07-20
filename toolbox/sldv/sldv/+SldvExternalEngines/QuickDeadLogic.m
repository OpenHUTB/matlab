




classdef QuickDeadLogic<SldvExternalEngine
    methods
        function eng=QuickDeadLogic
            eng.Name='QuickDeadLogic';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
                eng.ExternalKillCommand='kill-rte-kernel';
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
                eng.ExternalKillCommand='cmd.exe /c kill-rte-kernel.bat';
            end
            eng.CommandArguments={'-a','quickDeadLogic'};
            eng.UsesDVO=true;
        end
    end
end
