function fullName=getDiagramFullName(cbinfo)




    fullName='';
    editor=cbinfo.studio.App.getActiveEditor;
    if isvalid(editor)
        if(isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain'))
            fullName=SLStudio.Utils.getModelName(cbinfo);
        else
            diagram=editor.getDiagram;
            fullName=diagram.getFullName;
        end
    end
end
