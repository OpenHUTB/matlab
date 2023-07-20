function stateData=getMATLABEditorState




    stateData.editorsMap=containers.Map;

    editors=matlab.desktop.editor.getAll();
    stateData.dirtyMFiles=cell.empty;

    for editorIdx=1:numel(editors)
        curEditor=editors(editorIdx);
        curEditorFullName=curEditor.Filename;



        if exist(curEditorFullName,'file')==2

            stateData.editorsMap(curEditorFullName)=curEditor;
            if curEditor.Modified
                stateData.dirtyMFiles{end+1}=curEditorFullName;
            end
        end
    end
end


