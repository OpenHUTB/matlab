function completeOverride=executeCustomLicenseMW(hStep,command,varargin)



    completeOverride=false;
    switch(command)
    case 'initialize',
    case 'next'
    case 'callback',
        completeOverride=true;
        switch(varargin{1})
        case 'Help',
            hwconnectinstaller.helpView('custompage');
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

