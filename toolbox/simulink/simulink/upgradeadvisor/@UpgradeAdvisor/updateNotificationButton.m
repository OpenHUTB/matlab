function updateNotificationButton(system,action)




    alert=UpgradeAdvisor.AlertStatus(system);
    if(alert.getDisplayStatus())
        action.text=DAStudio.message('SimulinkUpgradeAdvisor:advisor:disableNotifications');
    else
        action.text=DAStudio.message('SimulinkUpgradeAdvisor:advisor:enableNotifications');
    end

end

