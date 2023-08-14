function setStatus(this,statusStr)



    if strcmp(this.Status,DAStudio.message('ModelAdvisor:engine:CancelBackgroundRun'))&&...
        this.isSleeping
        return;
    end
    this.Status=statusStr;
    if~isempty(this.MAExplorer)
        this.MAExplorer.setStatusMessage(this.Status);
        this.MAExplorer.UserData.findText.setText(this.Status);
    end
    dashboard=ModelAdvisorLite.GUIModelAdvisorLite.findMALiteDialog(this.systemName);
    if~isempty(dashboard)
        dashboard.getSource.setStatusText(this.Status);
        dashboard.refresh;
    end