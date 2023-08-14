function stringLabel=getLabel(entry)




    if ischar(entry)
        filePath=strtok(entry,'|');
        [~,dictFName,dictFExt]=fileparts(filePath);
        dictName=[dictFName,dictFExt];
        [~,~,suffix]=fileparts(entry);
        label=suffix(2:end);
    else
        dictName=strtok(entry.getPropValue('Path'),'/');
        label=entry.getDisplayLabel;
    end

    stringLabel=getString(message('Slvnv:rmide:DataFromDictionary',label,dictName));

end