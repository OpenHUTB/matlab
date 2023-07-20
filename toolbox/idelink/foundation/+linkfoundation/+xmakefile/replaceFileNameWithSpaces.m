function files=replaceFileNameWithSpaces(inFiles)



    files=cell(length(inFiles),1);
    for index=1:length(inFiles)
        file=linkfoundation.util.File(inFiles{index});
        if(file.containsSpaces())
            files{index}=file.ShortFullPathName;
        else
            files{index}=file.FullPathName;
        end
    end

end
