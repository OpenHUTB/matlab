




classdef XternalProveStub<SldvExternalEngine
    methods
        function eng=XternalProveStub
            eng.Name='Prove with Stubbing';
            if isunix
                eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoanalyzer'];
            else
                eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoanalyzer.exe');
            end
            eng.CommandArguments={'-a','proveStub'};
            eng.UsesDVO=true;
        end
    end
end
