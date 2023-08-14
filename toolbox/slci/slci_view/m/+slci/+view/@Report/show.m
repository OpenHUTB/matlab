


function show(obj)

    dockposition='Right';
    dockoption='Tabbed';

    if~obj.hasDialog
        dialogObj=slci.view.gui.ReportDialog(obj.getStudio);
        obj.setDialog(dialogObj);
    end

    obj.showPanel(obj.getDialog,dockposition,dockoption)
