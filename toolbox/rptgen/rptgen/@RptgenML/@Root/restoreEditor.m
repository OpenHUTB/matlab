function restoreEditor(this)






    this.setStateEdit();


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ListChangedEvent',this.getCurrentComponent())


    editor=this.Editor;
    if isa(editor,'DAStudio.Explorer')
        ime=DAStudio.imExplorer(editor);
        dlg=ime.getDialogHandle;
        if isa(dlg,'DAStudio.Dialog')
            dlg.restoreFromSchema;
        end


        nodesToUnhighlight=ime.getNodesToHighlight();
        nNodes=size(nodesToUnhighlight,1);
        for i=1:nNodes
            editor.unhighlight(nodesToUnhighlight{i,1});
        end
    end
    this.enableActions;
