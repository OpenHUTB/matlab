


function showPanel(obj,dialogObj,dockposition,dockoption)

    studio=obj.getStudio;

    if isempty(studio)

        DAStudio.Dialog(obj.fDialog);
        return;
    end

    id=dialogObj.id;
    title=dialogObj.title;

    cmpName=obj.getComp;
    comp=studio.getComponent(cmpName,id);
    if isempty(comp)
        assert(~isempty(dialogObj));
        dialog=GLUE2.DDGComponent(studio,id,dialogObj);

        dialog.setPreferredSize(-1,350);
        studio.registerComponent(dialog);
        studio.moveComponentToDock(dialog,title,dockposition,dockoption);
    else
        studio.showComponent(comp);
        studio.setActiveComponent(comp);
    end
