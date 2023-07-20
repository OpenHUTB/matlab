


function refresh(obj)

    if obj.hasDialog

        dialog=obj.getDialog;
        dialog.reloadData();
    else


        dialog=slci.view.gui.ResultReviewDialog(obj.getStudio);
        obj.setDialog(dialog);
    end
