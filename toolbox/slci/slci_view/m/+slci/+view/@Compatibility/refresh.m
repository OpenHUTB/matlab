


function refresh(obj)

    if obj.hasDialog

        dialog=obj.getDialog;
        dialog.reloadData();
    else


        dialog=slci.view.gui.CompatibilityDialog(obj.getStudio);
        obj.setDialog(dialog);
    end

