function cleanupMLFBEditorMap(obj)




    keys=obj.MLFBEditorMap.keys;
    for i=1:length(keys)
        key=keys{i};
        val=obj.MLFBEditorMap(key);
        newVal={};
        for j=1:length(val)
            ed=val{j};
            if isvalid(ed)&&~ed.closed
                editor=ed.ed;
                if~isempty(editor)&&editor.isvalid
                    newVal{end+1}=ed;%#ok<AGROW>
                end
            end
        end
        if isempty(newVal)
            obj.MLFBEditorMap.remove(key);
        else
            obj.MLFBEditorMap(key)=newVal;
        end
    end
