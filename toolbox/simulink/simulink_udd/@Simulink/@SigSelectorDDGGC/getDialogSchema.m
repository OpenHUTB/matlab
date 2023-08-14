function dlg=getDialogSchema(h,~)









    opts=h.TCPeer.getOptions;

    if opts.FilterVisible


        filterEdit.Type='edit';
        filterEdit.RowSpan=[1,1];
        filterEdit.ColSpan=[1,1];
        filterEdit.Graphical=true;
        filterEdit.Mode=true;
        filterEdit.ObjectMethod='applyFilter';
        filterEdit.MethodArgs={'%dialog'};
        filterEdit.ArgDataTypes={'handle'};
        filterEdit.Tag='sigselector_filterEdit';
        filterEdit.RespondsToTextChanged=true;
        filterEdit.PlaceholderText=DAStudio.message('Simulink:sigselector:FilterByName');
        filterEdit.Clearable=true;


        filterOptsShow.Type='pushbutton';
        filterOptsShow.Tag='sigselector_filterOptsExpand';
        filterOptsShow.ObjectMethod='setFilterOptions';
        filterOptsShow.MethodArgs={'%tag','%dialog'};
        filterOptsShow.ArgDataTypes={'string','handle'};
        filterOptsShow.RowSpan=[1,1];
        filterOptsShow.ColSpan=[2,2];
        filterOptsShow.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink_udd','@Simulink','@SigSelectorDDGGC','resources','filteroptions_expand.png');
        filterOptsShow.ToolTip=DAStudio.message('Simulink:sigselector:ToolTipFilterOptsShow');
        filterOptsShow.MaximumSize=[20,20];
        filterOptsShow.Visible=~h.ShowFilteringOptions;

        filterOptsHide.Type='pushbutton';
        filterOptsHide.Tag='sigselector_filterOptsCollapse';
        filterOptsHide.ObjectMethod='setFilterOptions';
        filterOptsHide.MethodArgs={'%tag','%dialog'};
        filterOptsHide.ArgDataTypes={'string','handle'};
        filterOptsHide.RowSpan=[1,1];
        filterOptsHide.ColSpan=[2,2];
        filterOptsHide.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink_udd','@Simulink','@SigSelectorDDGGC','resources','filteroptions_collapse.png');
        filterOptsHide.ToolTip=DAStudio.message('Simulink:sigselector:ToolTipFilterOptsHide');
        filterOptsHide.MaximumSize=[20,20];
        filterOptsHide.Visible=h.ShowFilteringOptions;


        filterOptsPanel.Type='group';
        filterOptsPanel.Name=DAStudio.message('Simulink:sigselector:FilterOptions');
        filterOptsPanel.Tag='sigselector_filterOptsGroup';
        filterOptsPanel.RowSpan=[2,2];
        filterOptsPanel.ColSpan=[1,2];
        filterOptsPanel.Visible=h.ShowFilteringOptions;
        filterOptsPanel.LayoutGrid=[2,1];



        filterOptsRegExp.Type='checkbox';
        filterOptsRegExp.Tag='sigselector_filterOptsRegExp';
        filterOptsRegExp.Name=DAStudio.message('Simulink:sigselector:RegExpOptionDDG');
        filterOptsRegExp.RowSpan=[1,1];
        filterOptsRegExp.ColSpan=[1,1];
        filterOptsRegExp.Graphical=true;
        filterOptsRegExp.ObjectMethod='setFilterOptions';
        filterOptsRegExp.MethodArgs={'%tag','%dialog'};
        filterOptsRegExp.ArgDataTypes={'string','handle'};

        filterOptsFlatList.Type='checkbox';
        filterOptsFlatList.Tag='sigselector_filterOptsFlatList';
        filterOptsFlatList.Name=DAStudio.message('Simulink:sigselector:FlatListOption');
        filterOptsFlatList.RowSpan=[2,2];
        filterOptsFlatList.ColSpan=[1,1];
        filterOptsFlatList.Graphical=true;
        filterOptsFlatList.ObjectMethod='setFilterOptions';
        filterOptsFlatList.MethodArgs={'%tag','%dialog'};
        filterOptsFlatList.ArgDataTypes={'string','handle'};
        filterOptsPanel.Items={filterOptsRegExp,filterOptsFlatList};
    end

    [treeitems,treename,listname,listitems]=constructTreeItems(h);
    istreevisible=~opts.FilterVisible||isempty(h.TCPeer.getFilterText)||~h.TCPeer.getFlatList;
    sigsTree.Name=treename;
    sigsTree.Tag='sigselector_signalsTree';
    sigsTree.Type='tree';
    sigsTree.ObjectMethod='selectSignalInTree';
    sigsTree.MethodArgs={'%dialog'};
    sigsTree.ArgDataTypes={'handle'};
    sigsTree.Graphical=true;
    sigsTree.TreeItems=treeitems;
    sigsTree.TreeMultiSelect=opts.TreeMultipleSelection;

    sigsTree.MinimumSize=h.MinimumSize;
    sigsTree.ExpandTree=~isempty(h.TCPeer.getFilterText);
    sigsTree.Visible=istreevisible;

    sigsList.Name=listname;
    sigsList.Tag='sigselector_signalsList';
    sigsList.Type='listbox';
    sigsList.ObjectMethod='selectSignalInList';
    sigsList.MethodArgs={'%dialog'};
    sigsList.ArgDataTypes={'handle'};
    sigsList.Graphical=true;
    sigsList.MultiSelect=opts.TreeMultipleSelection;
    sigsList.Entries=listitems;
    sigsList.UserData=listitems;
    sigsList.MinimumSize=h.MinimumSize;
    sigsList.Visible=~istreevisible;


    dlg.Type='panel';
    if opts.FilterVisible
        sigsTree.RowSpan=[3,3];
        sigsTree.ColSpan=[1,2];
        sigsList.RowSpan=[3,3];
        sigsList.ColSpan=[1,2];
        dlg.Items={filterOptsShow,filterEdit,filterOptsHide,filterOptsPanel,sigsTree,sigsList};
        dlg.LayoutGrid=[3,2];
        dlg.RowStretch=[0,0,1];
        dlg.ColStretch=[1,0];
    else

        sigsTree.RowSpan=[1,1];
        sigsTree.ColSpan=[1,1];
        dlg.Items={sigsTree};
        dlg.LayoutGrid=[1,1];
        dlg.RowStretch=1;
        dlg.ColStretch=1;
    end
end



