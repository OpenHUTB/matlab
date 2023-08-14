


function refresh(obj,~,~)

    if obj.hasDialog
        dialog=obj.getDialog;
        dialog.reloadData();
    end