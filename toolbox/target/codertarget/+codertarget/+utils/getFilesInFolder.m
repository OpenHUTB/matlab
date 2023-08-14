function files=getFilesInFolder(rootFolder)





    dirStruct=dir(rootFolder);
    files={};
    for i=1:length(dirStruct)
        candidate=dirStruct(i);
        if~candidate.isdir
            if isempty(files)
                files=candidate;
            else
                files(end+1)=candidate;%#ok<AGROW>
            end
        end
    end
end