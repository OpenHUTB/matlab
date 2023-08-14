function toggleCoderApp(cbinfo)





    if~coder.internal.toolstrip.license.isSimulinkCoder&&~coder.internal.toolstrip.license.isEmbeddedCoder

        return;
    end



    studio=cbinfo.studio;
    editor=studio.App.getActiveEditor;
    h=editor.blockDiagramHandle;
    if h==0
        return;
    end


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    cp.togglePerspective(studio);