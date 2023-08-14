function viewArea=getCurrentEditorView()









    editor=SLM3I.SLDomain.findLastActiveEditor();
    if~isempty(editor)
        canvas=editor.getCanvas();
        viewArea=canvas.SceneRectInView;
    else
        viewArea=[];
    end
end