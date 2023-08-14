function availablelist_cb(this,dlg,tag)








    selection=dlg.getWidgetValue(tag);
    if~isempty(selection)
        dlg.setEnabled('AllowButton',true);
        this.DialogData.selectedForAllow=selection;
    else
        dlg.setEnabled('AllowButton',false);
        this.DialogData.selectedForAllow=[];
    end

