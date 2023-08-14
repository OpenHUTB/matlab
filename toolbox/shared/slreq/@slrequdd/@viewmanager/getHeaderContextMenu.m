function menu=getHeaderContextMenu(this,header)%#ok<INUSD>


    am=DAStudio.ActionManager;
    menu=am.createPopupMenu(this.Explorer);
    action=am.createAction(this.Explorer);
    action.Tag='columnSelector';
    action.text=getString(message('Slvnv:slreq:SelectColumns'));


    action.callback='slreq.gui.ColumnSelector.show(''#?#standalone#?#'')';
    menu.addMenuItem(action);

    sorting=am.createAction(this.Explorer);
    sorting.Tag='clearSort';
    sorting.text=getString(message('Slvnv:slreq:ClearSort'));
    if strcmp(this.Explorer.SortColumn,'NULL')
        sorting.enabled='off';
    else
        sorting.enabled='on';
    end
    sorting.callback='slreq.gui.RequirementsEditor.sortColumnCallback(''clear'')';
    menu.addMenuItem(sorting);
end