function h=customize(h)




    h.updateTitle;

    h.setTreeTitle(DAStudio.message('Simulink:taskEditor:TaskEditorTreeTitle'));

    h.imme=DAStudio.imExplorer(h);
    h.showContentsOf(false);
    h.GroupingEnabled=true;
    h.GroupColumn='Block';
    h.HideGroupColumn=true;
    h.showGroupCount=false;
    h.SortColumn='Name';
    h.showDialogView(true);
    h.imme.enableListSorting(true,'Name',true);
    h.showListView(false);
    h.setListMultiSelect(false);

    h.enableFreezePane(false);
