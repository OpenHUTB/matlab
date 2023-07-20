function dlgH=getCurrentDialog(this)






    editorH=this.Editor;
    if isa(editorH,'DAStudio.Explorer')
        ime=DAStudio.imExplorer(this.Editor);
        dlgH=ime.getDialogHandle();
    else
        dlgH=[];
    end
