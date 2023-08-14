function dlgstruct=getDialogSchema(this,name)






    tabcontent=getMappingInformationTabSchema(this);
    mappinginfotab.Name=DAStudio.message('RTW:tfldesigner:MappingInfoTabName');
    mappinginfotab.Items={tabcontent};

    if~isa(this.object,'RTW.TflCustomization')

        tab4content=getbuildinfotabschema(this);
        buildTab.Name=DAStudio.message('RTW:tfldesigner:BuildInfoTabName');
        buildTab.Items={tab4content};
    end


    tab5content=geterrorlogtabschema(this);

    errorLogTab.Name=DAStudio.message('RTW:tfldesigner:ErrorLogTabName');
    errorLogTab.Items={tab5content};


    tabcont.Name='tabcont';
    tabcont.Type='tab';
    tabcont.ActiveTab=[];

    if~isa(this.object,'RTW.TflCustomization')
        if isempty(this.errLog)
            tabcont.Tabs={mappinginfotab,buildTab};
            if this.showBuildInfoTab
                tabcont.ActiveTab=1;
            end
        else
            tabcont.Tabs={mappinginfotab,buildTab,errorLogTab};
            if this.showErrLogTab
                tabcont.ActiveTab=2;
            elseif this.showBuildInfoTab
                tabcont.ActiveTab=1;
            end
        end
    else
        if isempty(this.errLog)
            tabcont.Tabs={mappinginfotab};
        else
            tabcont.Tabs={mappinginfotab,errorLogTab};
            if this.showErrLogTab
                tabcont.ActiveTab=1;
            end
        end
    end

    this.showErrLogTab=false;
    this.showBuildInfoTab=false;


    dlgstruct.DialogTitle=name;
    dlgstruct.EmbeddedButtonSet={'Help','Apply'};
    dlgstruct.PreApplyMethod='applyproperties';
    dlgstruct.PreApplyArgsDT={'handle'};
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs=...
    {[docroot,'/toolbox/ecoder/helptargets.map'],'tfl_base'};
    dlgstruct.Items={tabcont};


    this.widgetStructList=[];
    this.widgetTagList=[];



