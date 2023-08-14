






function removeDir(dirName)
    [status,~,~]=rmdir(dirName,'s');
    if~status&&sldv.code.internal.feature('warnRmdir')
        warnDirContent(dirName);
    end



    function fileList=getDirContent(dirName)
        elements=dir(dirName);
        files=elements(~[elements.isdir]);
        dirs=elements([elements.isdir]);

        fileList=cell(numel(files)+1,1);

        for ii=1:numel(files)
            f=files(ii);
            filePath=fullfile(f.folder,f.name);
            fileList{ii}=filePath;
        end

        fileList{end}=fullfile(dirName);

        for ii=1:numel(dirs)
            d=dirs(ii);
            if~any(strcmp(d.name,{'.','..'}))
                subDir=fullfile(dirName,d.name);
                fileList=[fileList;getDirContent(subDir)];%#ok;
            end
        end




        function warnDirContent(dirName)
            absoluteDir=polyspace.internal.getAbsolutePath(dirName);
            fileList=getDirContent(absoluteDir);

            warning('sldv_sfcn:cannotRemoveDir',...
            'Unable to remove directory %s\nFiles remaining:\n%s\n',...
            absoluteDir,...
            strjoin(fileList,newline));
