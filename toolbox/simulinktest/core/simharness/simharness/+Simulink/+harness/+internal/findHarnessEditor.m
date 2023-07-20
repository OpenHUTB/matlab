function editor=findHarnessEditor(harnessName)


    editor=GLUE2.Util.findAllEditors(harnessName);




    if isempty(editor)
        allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        for k=1:length(allStudios)
            actEditor=allStudios(k).App.getActiveEditor();
            if contains(actEditor.getName(),harnessName)
                editor=actEditor;
                break;
            end
        end
    end



    if length(editor)>1
        editor=editor(1);
    end

end
