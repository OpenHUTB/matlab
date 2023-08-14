


function status=getStatus(obj)

    status=false;

    if obj.hasDialog

        studio=obj.getStudio;
        cmpName=obj.fComp;

        id=obj.getDialog.id;
        comp=studio.getComponent(cmpName,id);

        status=~isempty(comp)&&comp.isVisible;
    end