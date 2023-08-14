function completeOverride=executeInstallComplete(hStep,command,varargin)




    completeOverride=false;
    switch(command)
    case 'initialize',
        if(isempty(hStep.StepData))
            xlateEnt=struct(...
            'Label_Download','',...
            'Label_Uninstall','',...
            'LongDescription','',...
            'Link','',...
            'Close','',...
            'Continue','',...
            'Finish','',...
            'DemoCheckbox','',...
            'ExtraInfoCheckbox','');
            xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','InstallComplete',xlateEnt);
            hStep.StepData.Labels=xlateEnt;
            hStep.StepData.Installer=hStep.getSetup().getInstaller();
            hStep.StepData.DemoCheckbox=true;
            hStep.StepData.ExtraInfoCheckbox=true;
        end
    case 'callback',
        completeOverride=true;
        assert(~isempty(hStep.StepData));
        switch(varargin{1})
        case 'Link',

            i_showDemoPage(hStep);
        case 'DemoCheckBox',
            hStep.StepData.DemoCheckbox=varargin{3};
        case 'ExtraInfoCheckBox',
            hStep.StepData.ExtraInfoCheckbox=varargin{3};
        case 'Help',
            hwconnectinstaller.helpView('installorupdatecomplete');
        otherwise,
            completeOverride=false;
        end
    case 'finish'
        hwconnectinstaller.internal.inform('Got the demos checkbox state: ');
        hwconnectinstaller.internal.inform(hStep.StepData.DemoCheckbox);
        hwconnectinstaller.internal.inform('Got the extra info checkbox state: ');
        hwconnectinstaller.internal.inform(hStep.StepData.ExtraInfoCheckbox);
        if(hStep.StepData.DemoCheckbox)
            i_showDemoPage(hStep);
        end
        if(hStep.StepData.ExtraInfoCheckbox)
            i_executeExtraInfo(hStep);
        end
    end


    function i_showDemoPage(hStep)
        hSetup=hStep.getSetup();
        hInstaller=hSetup.getInstaller();
        for i=1:numel(hSetup.SelectedPackage)
            pkgInfo=hSetup.PackageInfo(hSetup.SelectedPackage(i));
            hInstaller.showDemoPage(pkgInfo.Name);
        end


        function i_executeExtraInfo(hStep)
            hSetup=hStep.getSetup();
            hInstaller=hSetup.getInstaller();
            for i=1:numel(hSetup.SelectedPackage)
                pkgInfo=hSetup.PackageInfo(hSetup.SelectedPackage(i));
                spPkgName=pkgInfo.Name;
                pkg=hInstaller.getSpPkgInfo(spPkgName,struct('missingInfoAction','warning'));
                try
                    hInstaller.executeExtraInfoCmd(pkg);
                catch ME
                    warning(ME.identifier,ME.message);
                end
            end



