function entries=getArchiveEntries(basepath,files)






    [~,ia]=unique(files);
    files=files(sort(ia));


    if~isempty(files)
        inputs=struct('file','','fileDir','');
        inputs(numel(files))=inputs(1);
    end


    for i=1:length(files)
        filename=files{i};
        [fileIsDir,~]=isDirectory(basepath,filename);
        if fileIsDir
            inputs(i).fileDir=filename;
        else

            error('rptgen:rptgen:notADirectory','%s',getString(message('rptgen:rptgen:notADirectory',filename)));
        end

        inputs(i).file=filename;
    end


    entries=[];


    while~isempty(inputs)


        file=inputs(1).file;
        fileDir=inputs(1).fileDir;
        inputs(1)=[];


        [fileIsDir,dirContents]=isDirectory(basepath,file);

        if fileIsDir

            inputs=addDirectory(inputs,dirContents,file,fileDir);
        else


            entries(end+1).file=fullfile(basepath,file);%#ok<AGROW>
            entries(end).entry=convertSlash(file);
            entries(end).fileDir=fileDir;
        end
    end
end


function[fileIsDir,dirContents]=isDirectory(basepath,filename)


    dirContents=dir(fullfile(basepath,filename));
    dirContents={dirContents.name};
    fileIsDir=numel(dirContents)>1;
    if fileIsDir
        dirContents=setdiff(dirContents,{'.','..'});
    end
end


function inputs=addDirectory(inputs,dirContents,file,fileDir)



    for i=1:length(dirContents)
        inputs(end+1).file=fullfile(file,dirContents{i});%#ok<AGROW>
        inputs(end).fileDir=fileDir;
    end
end


function name=convertSlash(name)
    name=strrep(name,'\','/');
    if strncmp(name,'./',2)

        name=name(3:end);
    end
end