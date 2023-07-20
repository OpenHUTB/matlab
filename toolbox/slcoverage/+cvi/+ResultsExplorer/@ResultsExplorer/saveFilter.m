function saveFilter(obj,fullFileName)




    [path,fileName]=fileparts(fullFileName);
    if~isempty(fileName)
        obj.filterEditor.fileName=fullfile(path,fileName);
        obj.filterEditor.save(obj.filterEditor.fileName,true);
    end
end