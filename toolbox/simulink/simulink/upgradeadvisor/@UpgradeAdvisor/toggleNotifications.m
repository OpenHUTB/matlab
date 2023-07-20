function toggleNotifications()




    mdlAdvisor=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    explorer=mdlAdvisor.MAExplorer;

    if(isfield(explorer.UserData,'upgradeAction'))
        action=explorer.UserData.upgradeAction;
        status=strcmp(action.text,DAStudio.message('SimulinkUpgradeAdvisor:advisor:enableNotifications'));

        alert=UpgradeAdvisor.AlertStatus(mdlAdvisor.System);
        alert.setDisplayStatus(status);

        UpgradeAdvisor.updateNotificationButton(mdlAdvisor.System,action);
    end

end

