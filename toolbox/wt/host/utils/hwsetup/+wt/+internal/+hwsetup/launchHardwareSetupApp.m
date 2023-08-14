function launchHardwareSetupApp






    hspExists=which('matlab.hwmgr.internal.hwsetup.register.WTWorkflow');
    if(isempty(hspExists))

        error(message("wt:rfnoc:host:UHDInstallNotFound"));
    end
    workflow=matlab.hwmgr.internal.hwsetup.register.WTWorkflow;
    workflow.launch;
end
