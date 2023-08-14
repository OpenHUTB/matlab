function completeOverride=executeUpdateFirmware(hStep,command,varargin)




    completeOverride=false;
    switch(command)
    case 'initialize',
        if(isempty(hStep.StepData))
            xlateEnt=struct(...
            'Choose','',...
            'DescriptionNone','',...
            'DescriptionNotRequired','',...
            'AvailableDescription','');
            xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','Update',xlateEnt);
            hStep.StepData.Labels=xlateEnt;
            hStep.StepData.Choice=-1;
        end
    case 'callback',
        completeOverride=true;
        assert(~isempty(hStep.StepData));
        switch(varargin{1})
        case 'Choice',
            hStep.StepData.Choice=varargin{3};
        case 'Help',
            hwconnectinstaller.helpView('updatefirmware');
        otherwise,
            completeOverride=false;
        end
    case 'next'
        hwconnectinstaller.internal.inform('Got the install choice: ');

        hSetup=hStep.getSetup();
        h=hSetup.FwUpdater;

        selectedSetupWorkflow=hStep.StepData.List{hStep.StepData.Choice+1};


        selectedSetupBaseCode=hStep.StepData.BaseCodeList{hStep.StepData.Choice+1};



        fwUpdateSuperClassList=superclasses(selectedSetupWorkflow);
        if any(ismember(fwUpdateSuperClassList,...
            'matlab.hwmgr.internal.hwsetup.Workflow'))
            DAStudio.delayedCallback(@closeTargetupdater,hSetup);
            matlab.hwmgr.internal.hwsetup.launchHardwareSetupApp(selectedSetupWorkflow,selectedSetupBaseCode);
            completeOverride=true;
            return;
        end


        h.BaseCodeForSelectedSpPkg=selectedSetupBaseCode;
        newSteps=h.getFirmwareUpdateSteps(selectedSetupWorkflow);

        hSetup.addSteps(hStep,newSteps);

    end
end

function closeTargetupdater(hSetup)
    hSetup.cancel()
end
