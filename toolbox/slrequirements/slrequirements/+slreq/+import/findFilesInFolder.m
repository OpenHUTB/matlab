function files=findFilesInFolder(folder,ext)












    switch lower(ext)

    case '.reqif'

        opcExt=[ext,'z'];

    case{'.doc','.xls'}

        opcExt=[ext,'x'];

    otherwise

        opcExt=filesep;
    end

    files=findByExt(folder,ext,opcExt);

end

function files=findByExt(folder,ext1,ext2)
    folderEntries=dir(folder);
    files={};
    match2=[];
    for i=1:numel(folderEntries)
        entry=folderEntries(i);
        if entry.isdir
            continue;
        end
        entryName=entry.name;
        [~,~,fExt]=fileparts(entryName);
        if isempty(fExt)
            continue;
        end

        if strcmpi(fExt,ext1)
            files{end+1,1}=fullfile(folder,entryName);%#ok<AGROW>
        elseif strcmpi(fExt,ext2)
            files{end+1,1}=fullfile(folder,entryName);%#ok<AGROW>
            match2=[match2;length(files)];%#ok<AGROW>
        end
    end
    if~isempty(match2)
        ext2matches=files(match2);
        files(match2)=[];
        files=[files;ext2matches];
    end
end
