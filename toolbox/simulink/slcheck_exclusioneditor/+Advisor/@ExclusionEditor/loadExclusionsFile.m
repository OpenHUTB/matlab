function result=loadExclusionsFile(this,~)





    result=[];

    [filename,pathname]=uigetfile(...
    {'*.xml'},...
    DAStudio.message('slcheck:filtercatalog:OpenExclusionFile'),...
    '');


    if~isequal(filename,0)&&~isequal(pathname,0)
        [~,~,ext]=fileparts(filename);
        if~strcmpi(ext,'.xml')
            return;
        end
        filePath=fullfile(pathname,filename);

        try
            service=slcheck.AdvisorFilterService.getInstance;
            service.remove(this.model);
            previousValue=get_param(bdroot(this.model),'MAModelFilterFile');
            set_param(bdroot(this.model),'MAModelFilterFile',filePath);
            slcheck.getAdvisorFilterManager(this.model);
        catch ex
            if strcmp(ex.identifier,'slcheck:filtercatalog:SerializationFileBadFormat')
                set_param(bdroot(this.model),'MAModelFilterFile',previousValue);
                slcheck.getAdvisorFilterManager(this.model);
                throw ex;
            end
        end
        this.isSaveToSlx=false;
        this.isTableDataValid=false;
    end


    result=this.getTableData();


    window=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);
    window.bringToFront();
end


