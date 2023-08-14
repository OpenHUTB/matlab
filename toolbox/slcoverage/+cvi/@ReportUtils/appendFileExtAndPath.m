function fullFileName=appendFileExtAndPath(fileName,neededExt)

















    if isempty(fileName)
        fullFileName='';
    else
        [fpath,file,ext]=fileparts(convertStringsToChars(fileName));
        if isempty(ext)
            ext=neededExt;
        end

        fileWext=strcat(file,ext);


        if isempty(fpath)
            if isempty(which(fileWext))
                fpath=pwd;
            end
        end
        fullFileName=fullfile(fpath,fileWext);
    end