function UD=cant_undo(UD,exceptionContents)





    if nargin>1&&strcmp(exceptionContents,UD.undo.contents)
        return;
    end

    UD.undo.command='none';
    UD.undo.action='';
    UD.undo.contents='';
    UD.undo.index=-1;
    UD.undo.view=[];
    UD.undo.model=[];

    set([UD.menus.figmenu.EditMenuUndo,UD.toolbar.undo],'Enable','off');
    set([UD.menus.figmenu.EditMenuRedo,UD.toolbar.redo],'Enable','off');