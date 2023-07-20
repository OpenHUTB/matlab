function filename=lookForExistingFile(this,shortFilename,excluding)
    filename='';


    extensions=getAllValidFileExtensions(this);


    for idx=1:length(extensions)
        ext=extensions{idx};
        if isempty(strmatch(ext,excluding))&&exist([shortFilename,ext],'file')
            filename=[shortFilename,ext];
            break;
        end
    end
end