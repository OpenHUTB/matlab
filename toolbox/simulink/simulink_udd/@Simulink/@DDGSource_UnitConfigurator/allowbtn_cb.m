function allowbtn_cb(this,dlg,availablelist_tag)








    selection=dlg.getWidgetValue(availablelist_tag);
    if~isempty(selection)
        entries=dlg.getUserData(availablelist_tag);
        this.DialogData.UnitSystems=union(this.DialogData.UnitSystems,entries(selection+1));

    end
