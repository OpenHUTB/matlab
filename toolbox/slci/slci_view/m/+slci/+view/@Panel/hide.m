


function hide(obj)

    studio=obj.getStudio;

    if isempty(studio)
        return;
    end

    if obj.hasDialog
        dialogObj=obj.getDialog;

        id=dialogObj.id;
        cmpName=dialogObj.comp;
        comp=studio.getComponent(cmpName,id);
        if~isempty(comp)
            studio.hideComponent(comp);
        end
    end