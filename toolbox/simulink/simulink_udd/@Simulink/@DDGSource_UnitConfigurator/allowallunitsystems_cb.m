function allowallunitsystems_cb(this,dlg,value,availablelist_tag,selectedlist_tag,allow_tag,disallow_tag)








    if value==true
        this.DialogData.selectedForAllow=[];
        this.DialogData.selectedForDisallow=[];
        this.DialogData.UnitSystems=union(this.DialogData.UnitSystems,dlg.getUserData(availablelist_tag));
        dlg.setEnabled(availablelist_tag,false);
        dlg.setEnabled(selectedlist_tag,false);
        dlg.setEnabled(allow_tag,false);
        dlg.setEnabled(disallow_tag,false);
        this.DialogData.AllowAllUnitSystems='on';
    else
        dlg.setEnabled(availablelist_tag,true);
        dlg.setEnabled(selectedlist_tag,true);
        dlg.setEnabled(allow_tag,true);
        dlg.setEnabled(disallow_tag,true);
        this.DialogData.AllowAllUnitSystems='off';
    end
