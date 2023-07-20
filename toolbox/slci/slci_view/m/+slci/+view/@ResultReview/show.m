


function show(obj)

    dockposition='Bottom';
    dockoption='Tabbed';

    if~obj.hasDialog
        dialogObj=slci.view.gui.ResultReviewDialog(obj.getStudio);
        obj.setDialog(dialogObj);
    end

    obj.showPanel(obj.getDialog,dockposition,dockoption)
