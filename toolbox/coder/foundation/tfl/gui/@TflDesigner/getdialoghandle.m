function dghandle=getdialoghandle



    dghandle='';
    me=TflDesigner.getexplorer;
    if~isempty(me)&&ishandle(me)&&~isempty(me.imme)
        dghandle=me.imme.getDialogHandle;
    end
