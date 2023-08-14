



classdef MockingDVOEngine<SldvExternalEngine



    methods
        function eng=MockingDVOEngine
            eng.Name='MockingDVOEngine';
            if isunix
                if slfeature('SldvTaskingArchitecture')&&slavteng('feature','ResultsPolling')
                    executableName=fullfile(computer('arch'),'dash_test_stressapp');
                else
                    executableName=fullfile(computer('arch'),'mock_dvo');
                end
                eng.ExternalKillCommand='kill-rte-kernel';
            elseif ispc
                if slfeature('SldvTaskingArchitecture')&&slavteng('feature','ResultsPolling')
                    executableName=fullfile(computer('arch'),'dash_test_stressapp.exe');
                else
                    executableName=fullfile(computer('arch'),'mock_dvo.exe');
                end
                eng.ExternalKillCommand='cmd.exe /c kill-rte-kernel.bat';
            end
            eng.CommandPath='';

            eng.Command=fullfile(matlabroot,'bin',executableName);




            eng.CommandArguments={};
            eng.UsesDVO=false;
            eng.AcceptExternalResults=false;
            eng.ValidateSatisfiedResults=false;
            eng.FollowUpStrategy=0;
            eng.UsesEncryptedDVO=false;
        end
    end
end


