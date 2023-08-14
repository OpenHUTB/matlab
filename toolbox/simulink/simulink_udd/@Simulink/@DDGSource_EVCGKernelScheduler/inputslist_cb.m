function inputslist_cb(this,dlg)








    selection=dlg.getWidgetValue('inputsList');
    if~isempty(selection)
        dlg.setEnabled('PartitionButton',true);
    else
        dlg.setEnabled('PartitionButton',false);
    end

