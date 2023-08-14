



function show(obj)


    dockposition='Right';
    dockoption='Stacked';

    if~obj.hasDialog
        dialogObj=slci.view.gui.JustificationDialog(obj.getStudio);
        obj.setDialog(dialogObj);
    end

    obj.showPanel(obj.getDialog,dockposition,dockoption)
