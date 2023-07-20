function result=saveToModel(this)
    result=[];
    manager=slcheck.getAdvisorFilterManager(this.model);
    if isempty(this.TableData)&&manager.filters.Size==0
        return;
    end

    this.updateBackend();





    windowTitle=DAStudio.message('ModelAdvisor:engine:ModelAdvisorExclusionEditor');
    savedInText=DAStudio.message('slcheck:filtercatalog:Editor_SavedIn');





    sysroot=bdroot(this.model);
    if~isempty(get_param(sysroot,'MAModelFilterFile'))
        set_param(sysroot,'MAModelFilterFile','');
    end

    mdlObj=get_param(this.model,'Object');

    mdlObj.setDirty('ModelAdvisorFilters',true);
    this.isSaveToSlx=true;
    this.setDialogDirty(false);
    manager.saveToFile(slcheck.getFilterFilePath(this.model));


    windowTitle=[windowTitle,' - ',savedInText,' ',this.model];


    window=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);
    window.setTitle(windowTitle)
    this.refreshExclusions();
end