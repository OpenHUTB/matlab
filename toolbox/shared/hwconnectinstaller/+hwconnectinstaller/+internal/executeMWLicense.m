function completeOverride=executeMWLicense(hStep,command,varargin)



    completeOverride=false;
    switch(command)
    case 'initialize',
    case 'next'
    case 'callback',
        completeOverride=true;
        switch(varargin{1})
        case 'Help',
            hwconnectinstaller.helpView('mwsoftwarelicense');
        case 'EnableNext',
            hStep.EnableNextButton=varargin{4}.getWidgetValue('MWLicense_Step_Accept');
            varargin{4}.apply;
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
        hStep.EnableNextButton=0;

    end
