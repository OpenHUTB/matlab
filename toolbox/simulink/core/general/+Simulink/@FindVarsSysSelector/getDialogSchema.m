function dlgstruct=getDialogSchema(this,~)





    superObj=ModelAdvisor.SystemSelector;
    superObj.ModelObj=this.ModelObj;
    superObj.SelectedSystem=this.SelectedSystem;
    superObj.DialogInstruction=this.DialogInstruction;
    superObj.DialogTitle=this.DialogTitle;
    superObj.StartDialog=this.StartDialog;


    superObj.ShowLibraries=false;


    dlgstruct=superObj.getDialogSchema('');
    dlgstruct.Sticky=true;
    dlgstruct.DialogTag='Tag_FindVarsSysSelector';


    if this.ForRenameAll
        refreshVarUsage.Name=DAStudio.message('modelexplorer:DAS:FindVarsUpdateCache');
        refreshVarUsage.Type='checkbox';
        refreshVarUsage.Tag='cb_refreshVariableUsageInfo';
        refreshVarUsage.RowSpan=[3,3];
        refreshVarUsage.ColSpan=[1,1];
        refreshVarUsage.ObjectProperty='RefreshVarUsage';

        dlgstruct.Items=[dlgstruct.Items,refreshVarUsage];
        dlgstruct.LayoutGrid=[3,1];
        dlgstruct.RowStretch=[0,1,1];
    else
        searchSubModels.Name=DAStudio.message('modelexplorer:DAS:FindVarsOpenAndSearchRefMdls');
        searchSubModels.Type='checkbox';
        searchSubModels.Tag='cb_SearchSubModels';
        searchSubModels.RowSpan=[3,3];
        searchSubModels.ColSpan=[1,1];
        searchSubModels.ObjectProperty='SearchRefMdls';

        refreshVarUsage.Name=DAStudio.message('modelexplorer:DAS:FindVarsUpdateCache');
        refreshVarUsage.Type='checkbox';
        refreshVarUsage.Tag='cb_refreshVariableUsageInfo';
        refreshVarUsage.RowSpan=[4,4];
        refreshVarUsage.ColSpan=[1,1];
        refreshVarUsage.ObjectProperty='RefreshVarUsage';

        dlgstruct.Items=[dlgstruct.Items,searchSubModels,refreshVarUsage];
        dlgstruct.LayoutGrid=[4,1];
        dlgstruct.RowStretch=[0,1,1,1];
    end


