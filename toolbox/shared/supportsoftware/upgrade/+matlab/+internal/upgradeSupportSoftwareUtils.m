function upgradeSupportSoftwareUtils










    if(checkPreConditionsForSsiUpgrade)
        try
            previousSupportPackage=com.mathworks.supportsoftwarematlabmanagement.upgrade.InstalledSupportPackageUtils.getPreviouslyInstalledSupportPackages();
            if(~isempty(previousSupportPackage))
                connector.ensureServiceOn();
                com.mathworks.matlab_login.MatlabLogin.initializeLoginServices();
                com.mathworks.supportsoftwareclient.SupportSoftwareClient.bootstrapSsiInMatlab();
                url=com.mathworks.supportsoftwarematlabmanagement.upgrade.SsiUpgradeDialog.getSsiUpgradeUrl(previousSupportPackage);
                com.mathworks.addons.AddonsLauncher.showManager('installer',url);
            else
                disp(message('shared_supportsoftware:upgrade:upgradesupportsoftware:NoPrevSupportPackagesFound').getString);
            end
        catch ME
            error(message('shared_supportsoftware:upgrade:upgradesupportsoftware:GenericError',getReport(ME,'extended','hyperlinks','off')));
        end
    end
end

function upgradeFlag=checkPreConditionsForSsiUpgrade
    if(usejava('jvm'))
        if(usejava('desktop'))
            if(~matlab.internal.environment.context.isMATLABOnline)
                try
                    isLoginConnected=com.mathworks.supportsoftwarematlabmanagement.upgrade.SsiUpgradePreChecksUtils.isLoginConnected();
                catch ME
                    error(message('shared_supportsoftware:upgrade:upgradesupportsoftware:GenericError',getReport(ME,'extended','hyperlinks','off')));
                end
                if(isLoginConnected)
                    upgradeFlag=true;
                else
                    error(message('shared_supportsoftware:upgrade:upgradesupportsoftware:LoginNotConnectedError'));
                end
            else
                error(message('shared_supportsoftware:upgrade:upgradesupportsoftware:RunningFromMatlabOnlineError'));
            end
        else
            error(message('shared_supportsoftware:upgrade:upgradesupportsoftware:RunningWithNoDesktopError'));
        end
    else
        error(message('shared_supportsoftware:upgrade:upgradesupportsoftware:RunningWithNoJVMError'));
    end
end