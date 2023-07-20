function setupModelListeners(obj)


    studio=obj.studio;
    top=studio.App.blockDiagramHandle;
    editor=studio.App.getActiveEditor;
    bdh=editor.blockDiagramHandle;


    bd=get_param(bdh,'Object');
    obj.bdListeners={simulinkcoder.internal.CodePerspectiveListener(bd,obj)};



    if(top~=bdh)
        bd=get_param(top,'Object');
        obj.bdListeners{end+1}=simulinkcoder.internal.CodePerspectiveListener(bd,obj);
    end


