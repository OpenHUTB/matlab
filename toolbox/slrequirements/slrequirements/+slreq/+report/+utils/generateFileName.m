function filename=generateFileName(baseName,extName)




    [pathstr,fname,fext]=fileparts(baseName);
    if isempty(fext)
        fext=extName;
    end
    if isempty(pathstr)
        pathstr=pwd;
    end

    nameWithoutIndex=regexp(fname,'(.*?)\(\d+\)$','tokens');

    if~isempty(nameWithoutIndex)
        fname=nameWithoutIndex{1}{1};
    end

    fullfilepath=fullfile(pathstr,[fname,fext]);
    index=0;
    while exist(fullfilepath,'file')==2
        index=index+1;
        nfname=[fname,'(',num2str(index),')'];
        fullfilepath=fullfile(pathstr,[nfname,fext]);
    end
    filename=fullfilepath;
end