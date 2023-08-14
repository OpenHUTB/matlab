




classdef FxpRangeComputation<SldvExternalEngine
    methods
        function eng=FxpRangeComputation
            eng.Name='FxpRangeComputation';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvofxp'];
                eng.ExternalKillCommand='kill-rte-kernel';
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvofxp.exe');
                eng.ExternalKillCommand='cmd.exe /c kill-rte-kernel.bat';
            end
            eng.UsesDVO=true;
        end
    end
end
