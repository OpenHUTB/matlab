function result=saveToDefaultLocation(this)
    result=[];
    manager=slcheck.getAdvisorFilterManager(this.model);

    if this.isSaveToSlx
        result=this.saveToModel();
    else
        if isempty(this.TableData)&&manager.filters.Size==0
            return;
        end

        this.updateBackend();
        this.setDialogDirty(false);

        windowTitle=DAStudio.message('ModelAdvisor:engine:ModelAdvisorExclusionEditor');
        savedInText=DAStudio.message('slcheck:filtercatalog:Editor_SavedIn');

        filePath=slcheck.getFilterFilePath(modelName);
        manager.saveToFile(filePath);
        windowTitle=[windowTitle,' - ',savedInText,' ',filePath];
        window=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);
        window.setTitle(windowTitle);
        this.refreshExclusions();
    end

end
