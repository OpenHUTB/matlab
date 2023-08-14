function selectedlist_cb(this,dlg,tag)








    selection=dlg.getWidgetValue(tag);
    if~isempty(selection)
        dlg.setEnabled('DisallowButton',true);
        this.DialogData.selectedForDisallow=selection;
    else
        dlg.setEnabled('DisallowButton',false);
        this.DialogData.selectedForDisallow=[];
    end

