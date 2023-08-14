function data=getCodeData(obj)


    data=[];

    names=obj.files;
    if isempty(names)||~iscell(names)
        data.files={};
        return;
    end

    n=length(names);
    files={};
    for i=1:n
        name=names{i};
        list=dir(name);
        for j=1:length(list)
            item=list(j);
            moreFiles=loc_getFiles(item);
            files=[files,moreFiles];%#ok<AGROW>
        end
    end


    map=containers.Map;
    for i=1:length(files)
        file=files{i};
        name=file.name;
        if~map.isKey(name)
            map(name)=file;
        end
    end

    data.files=map.values;

    function files=loc_getFiles(item)
        files={};
        fullName=fullfile(item.folder,item.name);
        if item.isdir
            if~strcmp(item.name,'.')&&~strcmp(item.name,'..')
                list=dir(fullName);
                for i=1:length(list)
                    files=[files,loc_getFiles(list(i))];%#ok<AGROW>
                end
            end
        else
            fid=fopen(fullName,'r');
            if fid~=-1
                code=fscanf(fid,'%c');
                fclose(fid);
                item.code=code;
            end
            files={item};
        end



        function files=loc_getFolder(folderName)
            files={};
            list=dir(folderName);
            for i=1:length(list)
                item=list(i);
                if strcmp(item.name,'.')||strcmp(item.name,'..')
                    continue;
                end
                if item.isdir
                    filesInFolder=loc_getFolder(item.name);
                    files=[files,filesInFolder];%#ok<AGROW>
                else
                    files{end+1}=loc_getFile(item.name);%#ok<AGROW>
                end
            end

