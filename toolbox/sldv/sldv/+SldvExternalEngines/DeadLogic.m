




classdef DeadLogic<SldvExternalEngine
    methods
        function eng=DeadLogic
            eng.Name='DeadLogic';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
                eng.ExternalKillCommand='kill-rte-kernel';
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
                eng.ExternalKillCommand='cmd.exe /c kill-rte-kernel.bat';
            end
            eng.CommandArguments={'-a','deadLogic'};
            eng.UsesDVO=true;
        end
    end
end
