function dpigenerator_MATLAB_HDLToolChainCompile(modelName,configObj,srcPath,GenCodeOnly)




    currentDir=pwd;
    restoreDir=onCleanup(@()cd(currentDir));
    cd(srcPath);

    IsQuestaSimTC=~isempty(strfind(configObj.Toolchain,'QuestaSim/Modelsim'));

    IsXceliumTC=~isempty(strfind(configObj.Toolchain,'Xcelium (64-bit Linux)'));

    if IsQuestaSimTC||IsXceliumTC

        [~,~]=system(['rm ',modelName,'_rtw.mk']);
        if ispc

            [~,~]=system('rm *.rsp');

            [~,~]=system('rm *.bat');
        end

        if IsQuestaSimTC
            HDL_SimulatorName='Questasim\Modelsim';
            ExecuteCommand='vsim';
            ExecuteUtility='vsim';
            Extension='.do';
        else
            HDL_SimulatorName='Xcelium';
            ExecuteCommand='xrun';
            ExecuteUtility='sh';
            Extension='.sh';
        end

        ExecuteScript=isempty(GenCodeOnly);

        AreBothWin32=strcmp(computer,'PCWIN')&&~isempty(strfind(configObj.Toolchain,'32-bit Windows'));
        AreBothWin64=strcmp(computer,'PCWIN64')&&~isempty(strfind(configObj.Toolchain,'64-bit Windows'));
        AreBothLinux=isunix&&(~isempty(strfind(configObj.Toolchain,'64-bit Linux'))||~isempty(strfind(configObj.Toolchain,'32-bit Linux')));
        if(AreBothWin64||AreBothWin32||AreBothLinux)&&ExecuteScript

            dpigenerator_disp(['Executing simulator script using ',ExecuteCommand,' on system path']);

            [status,~]=system([ExecuteCommand,' -version']);
            if status

                warning(message('HDLLink:DPIG:NoToolOnPath',HDL_SimulatorName));
            else


                [status,result]=system([ExecuteUtility,' < ',modelName,Extension]);
                if status
                    error(message('HDLLink:DPIG:SimulatorFailedToBuild',HDL_SimulatorName,result));
                else
                    dpigenerator_disp('Successful script execution.');
                end
            end
        end

    end
end


