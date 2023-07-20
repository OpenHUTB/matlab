function loadFilter(obj,fullFileName)




    obj.filterEditor.reset();
    [path,fileName]=fileparts(fullFileName);

    obj.filterEditor.fileName=fullfile(path,fileName);

    obj.filterEditor.load(fullFileName);
    if obj.filterEditor.hasUnappliedChanges
        obj.filterEditor.lastFilterElement={'dummy'};





    end
end