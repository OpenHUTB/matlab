function completeOverride=executeVerifyDetails(hStep,command,varargin)



    completeOverride=false;
    switch(command)
    case 'initialize',
        if(isempty(hStep.StepData))
            xlateEnt=struct(...
            'Description','',...
            'Introduction','',...
            'Warning','',...
            'LicenseNote','',...
            'LicenseNoteNoTP','',...
            'Download','',...
            'Skipping','');
            xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','VerifyDetails',xlateEnt);
            hStep.StepData.Labels=xlateEnt;
            hStep.StepData.Installer=hStep.getSetup().getInstaller();
            hStep.StepData.Icon=fullfile(matlabroot,'toolbox','shared','hwconnectinstaller','resources','warning.png');
            hStep.StepData.InstallerMsg=hStep.StepData.Labels.Warning;
        end
    case 'callback',
        completeOverride=true;
        switch(varargin{1})
        case 'Help',
            hwconnectinstaller.helpView('verifydetails');
        otherwise,
            completeOverride=false;
        end
    case 'back'



        xlateEnt=struct('Install','','None','');
        xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','SelectPackage',xlateEnt);
        hSetup=hStep.getSetup();
        hInstaller=hSetup.getInstaller();
        for i=1:length(hSetup.PackageInfo)




            if~isequal(hSetup.PackageInfo(i).Action,xlateEnt.None)
                sp=hInstaller.getSpPkgInfo(hSetup.PackageInfo(i).Name);
                if isempty(sp)
                    hSetup.PackageInfo(i).Action=xlateEnt.Install;
                end
            end
        end
    end

