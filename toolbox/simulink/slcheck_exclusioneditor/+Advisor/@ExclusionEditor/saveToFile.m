function result=saveToFile(this,~)




    result=[];
    if isempty(this.TableData)
        return;
    end

    this.updateBackend();

    manager=slcheck.getAdvisorFilterManager(this.model);




    windowTitle=DAStudio.message('ModelAdvisor:engine:ModelAdvisorExclusionEditor');
    savedInText=DAStudio.message('slcheck:filtercatalog:Editor_SavedIn');




    [filename,pathname]=uiputfile(...
    {'*.xml';'*.*'},...
    DAStudio.message('slcheck:filtercatalog:SaveExclusions'),...
    '');


    if~isequal(filename,0)&&~isequal(pathname,0)
        filePath=fullfile(pathname,filename);
        manager.saveToFile(filePath);


        sysroot=bdroot(this.model);
        set_param(sysroot,'MAModelFilterFile',filePath);

        if(this.isSaveToSlx)
            mdlObj=get_param(this.model,'Object');
            mdlObj.setDirty('ModelAdvisorFilters',true);
        end
        this.isSaveToSlx=false;

        windowTitle=[windowTitle,' - ',savedInText,' ',filePath];
    end
    this.setDialogDirty(false);
    window=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);
    window.setTitle(windowTitle)
    this.refreshExclusions();
end


