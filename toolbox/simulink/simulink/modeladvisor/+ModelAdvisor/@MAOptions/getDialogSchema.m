function dlg=getDialogSchema(this)





    maobj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(maobj,'Simulink.ModelAdvisor')
        if strcmp(maobj.CustomTARootID,'_modeladvisor_')
            fullDialog=true;
        else
            fullDialog=false;
        end
    else
        fullDialog=true;
    end


    MAOptions.Type='group';
    MAOptions.Name='';
    MAOptions.Flat=true;
    MAOptions.Items={};
    row=0;

    row=row+1;
    UIGroup=generateUIGroup(this,row,fullDialog);
    MAOptions.Items{end+1}=UIGroup;

    if fullDialog
        row=row+1;
        ReportGroup=generateReportGroup(row);
        MAOptions.Items{end+1}=ReportGroup;
        row=row+1;
        if Advisor.Utils.license('test','Distrib_Computing_Toolbox')==1
            RunInBackgroundGroup=generateRunInBackgroundGroup(row);
            MAOptions.Items{end+1}=RunInBackgroundGroup;
        end
        row=row+1;
        EnableCustomizationCacheGroup=generateEnableCustomizationCacheGroup(row);
        MAOptions.Items{end+1}=EnableCustomizationCacheGroup;
    end

    MAOptions.LayoutGrid=[row,1];

    dlg.Items={MAOptions};
    dlg.DialogTag=ModelAdvisor.MAOptions.getDialogTag(this.mdlName);
    dlg.StandaloneButtonSet={'Apply','OK','Cancel'};
    dlg.DialogTitle=DAStudio.message('ModelAdvisor:engine:ModelAdvisorPreferences');
    dlg.DialogRefresh=true;
    dlg.PostApplyMethod='postApply';
    dlg.DisplayIcon=fullfile('toolbox','simulink','simulink','modeladvisor','resources','ma.png');
end


function groupStruct=generateUIGroup(this,grouprow,fullDialog)
    mp=ModelAdvisor.Preferences;
    groupStruct.Type='group';
    groupStruct.Name=DAStudio.message('ModelAdvisor:engine:UserInterface');
    groupStruct.RowSpan=[grouprow,grouprow];
    groupStruct.ColSpan=[1,1];
    groupStruct.Items={};
    row=0;

    if fullDialog
        row=row+1;
        DefaultMAUI.Name=DAStudio.message('ModelAdvisor:engine:DefaultMode');
        DefaultMAUI.Entries=this.DefaultMAType;
        DefaultMAUI.Tag='DefaultMAType';
        DefaultMAUI.Type='combobox';
        DefaultMAUI.RowSpan=[row,row];
        currentVal=modeladvisorprivate('modeladvisorutil2','DefaultMAUI');
        DefaultMAUI.Value=this.DefaultMAType{this.getStringIdx(currentVal)};
        groupStruct.Items{end+1}=DefaultMAUI;

        row=row+1;
        checkbox=[];
        checkbox.Type='checkbox';
        checkbox.Name=DAStudio.message('ModelAdvisor:engine:ShowByProduct');
        checkbox.RowSpan=[row,row];
        checkbox.ColSpan=[1,1];
        checkbox.Value=mp.ShowByProduct;
        checkbox.Tag='ShowByProduct';
        groupStruct.Items{end+1}=checkbox;

        row=row+1;
        checkbox=[];
        checkbox.Type='checkbox';
        checkbox.Name=DAStudio.message('ModelAdvisor:engine:ShowByTask');
        checkbox.RowSpan=[row,row];
        checkbox.ColSpan=[1,1];
        checkbox.Value=mp.ShowByTask;
        checkbox.Tag='ShowByTask';
        groupStruct.Items{end+1}=checkbox;

        row=row+1;
        checkbox=[];
        checkbox.Type='checkbox';
        checkbox.Name=DAStudio.message('ModelAdvisor:engine:ShowSourceTab');
        checkbox.RowSpan=[row,row];
        checkbox.ColSpan=[1,1];
        checkbox.Value=mp.ShowSourceTab;
        checkbox.Tag='ShowSourceTab';
        groupStruct.Items{end+1}=checkbox;

        row=row+1;
        checkbox=[];
        checkbox.Type='checkbox';
        checkbox.Name=DAStudio.message('ModelAdvisor:engine:ShowExclusionTab');
        checkbox.RowSpan=[row,row];
        checkbox.ColSpan=[1,1];
        checkbox.Value=mp.ShowExclusionTab;
        checkbox.Tag='ShowExclusionTab';
        groupStruct.Items{end+1}=checkbox;
    end

    row=row+1;
    checkbox=[];
    checkbox.Type='checkbox';
    checkbox.Name=DAStudio.message('ModelAdvisor:engine:ShowAccordion');
    checkbox.RowSpan=[row,row];
    checkbox.ColSpan=[1,1];
    checkbox.Value=mp.ShowAccordion;
    checkbox.Tag='ShowAccordion';
    groupStruct.Items{end+1}=checkbox;

    groupStruct.LayoutGrid=[row,1];
end

function groupStruct=generateReportGroup(grouprow)
    mp=ModelAdvisor.Preferences;
    groupStruct.Type='group';
    groupStruct.Name=DAStudio.message('ModelAdvisor:engine:Report');
    groupStruct.RowSpan=[grouprow,grouprow];
    groupStruct.ColSpan=[1,1];
    groupStruct.Items={};
    row=0;

    row=row+1;
    checkbox=[];
    checkbox.Type='checkbox';
    checkbox.Name=DAStudio.message('ModelAdvisor:engine:ShowExclusions');
    checkbox.RowSpan=[row,row];
    checkbox.ColSpan=[1,1];
    checkbox.Value=mp.ShowExclusionsInRpt;
    checkbox.Tag='ShowExclusionsInRpt';
    groupStruct.Items{end+1}=checkbox;

    groupStruct.LayoutGrid=[row,1];
end


function groupStruct=generateRunInBackgroundGroup(grouprow)
    mp=ModelAdvisor.Preferences;
    groupStruct.Type='group';
    groupStruct.Name=DAStudio.message('ModelAdvisor:engine:RunInBackgroundPrefGroup');
    groupStruct.RowSpan=[grouprow,grouprow];
    groupStruct.ColSpan=[1,1];
    groupStruct.Items={};
    row=0;

    row=row+1;
    runInBackgroundDefault=[];
    runInBackgroundDefault.Type='checkbox';
    runInBackgroundDefault.Name=DAStudio.message('ModelAdvisor:engine:RunInBackgroundPref');
    runInBackgroundDefault.RowSpan=[row,row];
    runInBackgroundDefault.ColSpan=[1,1];
    runInBackgroundDefault.Value=mp.RunInBackground;
    runInBackgroundDefault.Tag='RunInBackground';
    groupStruct.Items{end+1}=runInBackgroundDefault;
    groupStruct.LayoutGrid=[row,1];
end

function groupStruct=generateEnableCustomizationCacheGroup(grouprow)
    mp=ModelAdvisor.Preferences;
    groupStruct.Type='group';
    groupStruct.Name=DAStudio.message('ModelAdvisor:engine:EnableCustomizationCacheGroup');
    groupStruct.RowSpan=[grouprow,grouprow];
    groupStruct.ColSpan=[1,1];
    groupStruct.Items={};
    row=0;












    row=row+1;
    updateCustomizationCache=[];
    updateCustomizationCache.Type='pushbutton';
    updateCustomizationCache.Name=DAStudio.message('ModelAdvisor:engine:UpdateCustomizationCachePref');
    updateCustomizationCache.RowSpan=[row,row];
    updateCustomizationCache.ColSpan=[1,1];
    updateCustomizationCache.MatlabMethod='Advisor.Manager.update_customizations';
    updateCustomizationCache.Tag='UpdateCustomizationCache';
    groupStruct.Items{end+1}=updateCustomizationCache;
    groupStruct.LayoutGrid=[row,1];
end
