


function show(obj)

    studio=obj.getStudio;

    if isempty(studio)

        DAStudio.Dialog(studio);
        return;
    end

    dialogObj=obj.getDialog;

    id=dialogObj.id;
    title=dialogObj.title;
    dockposition=dialogObj.dockposition;
    dockoption=dialogObj.dockoption;
    cmpName=dialogObj.comp;

    comp=studio.getComponent(cmpName,id);
    if isempty(comp)
        assert(~isempty(dialogObj));
        dialog=GLUE2.DDGComponent(studio,id,dialogObj);
        studio.registerComponent(dialog);
        studio.moveComponentToDock(dialog,title,dockposition,dockoption);
    else
        studio.showComponent(comp);
        studio.setActiveComponent(comp);
    end
