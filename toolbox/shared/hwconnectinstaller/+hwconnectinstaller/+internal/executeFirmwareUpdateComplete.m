function completeOverride=executeFirmwareUpdateComplete(hStep,command,varargin)





    completeOverride=false;
    switch(command)
    case 'initialize',
        if(isempty(hStep.StepData))
            xlateEnt=struct(...
            'Message','',...
            'DemoCheckbox','');
            xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','FirmwareUpdateComplete',xlateEnt);
            hStep.StepData.Labels=xlateEnt;
            hStep.StepData.Checkbox=true;
        end
    case 'callback',
        completeOverride=true;
        assert(~isempty(hStep.StepData));
        switch(varargin{1})
        case 'CheckBox',
            hStep.StepData.Checkbox=varargin{3};
        case 'Help',
            hwconnectinstaller.helpView('firmwareupdatecomplete');
        otherwise,
            completeOverride=false;
        end
    case 'finish'
        hwconnectinstaller.internal.inform('Got the demos checkbox state: ');
        hwconnectinstaller.internal.inform(hStep.StepData.Checkbox);
        hSetup=hStep.getSetup();
        fwUdpater=hSetup.FwUpdater;

        hSetup.freezeExplorer();
        if(hStep.StepData.Checkbox)
            matlabshared.supportpkg.internal.ssi.openExamplesForBaseCodes(...
            cellstr(fwUdpater.BaseCodeForSelectedSpPkg),matlabshared.supportpkg.internal.getSupportPackageRootNoCreate());
        end
        hSetup.unfreezeExplorer();
    end
