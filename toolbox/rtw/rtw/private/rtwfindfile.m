function filelist=rtwfindfile(dirlist,extlist,exclude)








    if~iscell(dirlist)
        tmp=dirlist;clear dirlist;dirlist{1}=tmp;
    end

    if~iscell(extlist)
        tmp=extlist;clear extlist;extlist{1}=tmp;
    end

    if nargin<3
        exclude='';
    end

    filelistall=findAllFilesInDir(dirlist,exclude);
    filelist='';
    extlist=strcat('.',extlist);

    for j=1:length(extlist)
        extension=extlist{j};
        sizeOfExt=length(extension)-1;
        fileext='';
        for i=1:length(filelistall)
            fileext{i}=filelistall{i}(end-sizeOfExt:end);
        end
        hasExtension=strcmpi(fileext,extension);
        filelist=[filelist,filelistall(hasExtension)];
        filelistall=filelistall(~hasExtension);
    end

    function filelist=findAllFilesInDir(dirlist,exclude)
        filelist={};
        sep=filesep;
        for i=1:length(dirlist)
            if any(strcmp(dirlist{i},exclude))
                continue
            end
            dirEntries=dir(dirlist{i});

            subdirlist={dirEntries(find([dirEntries.isdir])).name};
            subfilelist={dirEntries(find([dirEntries.isdir]==0)).name};

            if~isempty(subfilelist);
                filelist=[filelist,strcat(dirlist{i},sep,subfilelist)];
            end

            filterIdx=cellfun(@(x)~any(strcmp(x,exclude)),filelist);
            filelist=filelist(filterIdx);

            subdirlist=...
            subdirlist(~(strcmp('.',subdirlist)|strcmp('..',subdirlist)));

            if~isempty(subdirlist)
                directories=strcat([dirlist{i},sep],subdirlist);
                filelist=[filelist,findAllFilesInDir(directories,exclude)];
            end
        end







