function file=read(obj,data)




    key=data.Id;


    if~obj.iskeyInDB(key)
        file=char.empty;
        return;
    end


    id=obj.getFromDb(key);

    if isequal(id,'NoPreview')
        file=fullfile(matlabroot,'toolbox','evolutions',...
        'evolutions','+evolutions','+internal','resources','layout',...
        'NoPreview.html');
        return;
    end

    file=getStorageService(obj).read(id);
end
