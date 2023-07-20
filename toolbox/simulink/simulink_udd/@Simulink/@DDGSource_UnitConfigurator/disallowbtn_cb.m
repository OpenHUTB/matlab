function disallowbtn_cb(this,dlg,selectedlist_tag)








    selection=dlg.getWidgetValue(selectedlist_tag);
    if~isempty(selection)
        entries=dlg.getUserData(selectedlist_tag);
        this.DialogData.UnitSystems=setdiff(this.DialogData.UnitSystems,entries(selection+1));

    end
