function close()





    mdlAdvisor=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if~isempty(mdlAdvisor)&&...
        strcmp(mdlAdvisor.CustomTARootID,UpgradeAdvisor.UPGRADE_GROUP_ID)

        mdlAdvisor.closeExplorer;
    end

end
