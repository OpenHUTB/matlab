


function status=getStatus(obj)

    status=false;

    if obj.hasDialog

        studio=obj.getStudio;

        id=obj.getDialog.id;
        cmpName=obj.getDialog.comp;
        comp=studio.getComponent(cmpName,id);

        status=~isempty(comp)&&comp.isVisible;
    end