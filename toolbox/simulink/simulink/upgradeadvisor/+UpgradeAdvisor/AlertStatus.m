classdef AlertStatus<handle









    properties(Constant,Hidden)
        UPGRADED_VERSION_PARAM='DisableUpgradeWarningsForVersion';
        UPGRADE_PREF_GROUP='SimulinkUpgradeWarnings';
        UPGRADE_PREF_ENABLED='enabled';
    end


    properties(Access=private)
        Model;
    end


    methods(Access=public)

        function alert=AlertStatus(model)
            alert.Model=bdroot(model);
        end

        function display=getDisplayStatus(alert)
            simulinkVersion=simulink_version;
            display=alert.getSystemDisplayStatus(simulinkVersion)&&...
            alert.getModelDisplayStatus(simulinkVersion);
        end

        function setDisplayStatus(alert,status)
            if(status)
                startAlerts(alert);
            else
                stopAlerts(alert);
            end
        end

    end


    methods(Static,Access=public)

        function setAlertsEnabled(enabled)
            if(enabled)
                UpgradeAdvisor.AlertStatus.enableAlerts();
            else
                UpgradeAdvisor.AlertStatus.disableAlerts();
            end
        end

    end


    methods(Access=private)

        function display=getModelDisplayStatus(alert,simulinkVersion)
            if(alert.hasUpgradeParameter())
                upgradeRelease=get_param(alert.Model,UpgradeAdvisor.AlertStatus.UPGRADED_VERSION_PARAM);
                upgradeVersion=simulink_version(upgradeRelease);
                display=UpgradeAdvisor.AlertStatus.compareReleases(upgradeVersion,simulinkVersion);
            else
                display=true;
            end
        end

        function startAlerts(alert)
            alert.ensureLibraryUnlocked();
            if(alert.hasUpgradeParameter())
                delete_param(alert.Model,UpgradeAdvisor.AlertStatus.UPGRADED_VERSION_PARAM);
            end
        end

        function stopAlerts(alert)
            simulinkVersion=alert.getSimulinkVersion();
            alert.ensureLibraryUnlocked();
            if(alert.hasUpgradeParameter())
                set_param(alert.Model,UpgradeAdvisor.AlertStatus.UPGRADED_VERSION_PARAM,simulinkVersion);
            else
                add_param(alert.Model,UpgradeAdvisor.AlertStatus.UPGRADED_VERSION_PARAM,simulinkVersion);
            end
        end

        function hasParam=hasUpgradeParameter(alert)
            params=get_param(alert.Model,'ObjectParameters');
            hasParam=isfield(params,UpgradeAdvisor.AlertStatus.UPGRADED_VERSION_PARAM);
        end

        function ensureLibraryUnlocked(alert)
            params=get_param(alert.Model,'ObjectParameters');
            if(isfield(params,'Lock'))
                set_param(alert.Model,'Lock','off');
            end
        end

    end


    methods(Static,Access=private)

        function release=getSimulinkVersion()
            version=simulink_version;
            release=version.release;
        end

        function display=compareReleases(upgradeVersion,simulinkVersion)
            display=upgradeVersion.valid&&...
            simulinkVersion.valid&&...
            simulinkVersion>upgradeVersion;
        end

        function display=getSystemDisplayStatus(simulinkVersion)
            if(UpgradeAdvisor.AlertStatus.hasUpgradePreference())
                upgradeRelease=getpref(UpgradeAdvisor.AlertStatus.UPGRADE_PREF_GROUP,...
                UpgradeAdvisor.AlertStatus.UPGRADE_PREF_ENABLED);
                upgradeVersion=simulink_version(upgradeRelease);
                display=UpgradeAdvisor.AlertStatus.compareReleases(upgradeVersion,simulinkVersion);
            else
                display=true;
            end
        end

        function enableAlerts()
            if(UpgradeAdvisor.AlertStatus.hasUpgradePreference())
                rmpref(UpgradeAdvisor.AlertStatus.UPGRADE_PREF_GROUP,...
                UpgradeAdvisor.AlertStatus.UPGRADE_PREF_ENABLED);
            end
        end

        function disableAlerts()
            simulinkVersion=UpgradeAdvisor.AlertStatus.getSimulinkVersion();
            setpref(UpgradeAdvisor.AlertStatus.UPGRADE_PREF_GROUP,...
            UpgradeAdvisor.AlertStatus.UPGRADE_PREF_ENABLED,...
            simulinkVersion);
        end

        function hasPref=hasUpgradePreference()
            hasPref=ispref(UpgradeAdvisor.AlertStatus.UPGRADE_PREF_GROUP,...
            UpgradeAdvisor.AlertStatus.UPGRADE_PREF_ENABLED);
        end

    end


end

