function fid=createFile(filePath,targetDir)




    if nargin<2
        targetDir=pwd;
    end

    currentDir=pwd;
    cd(targetDir);

    fileFolder=fileparts(filePath);
    downstream.tool.createDir(fileFolder);

    fid=fopen(filePath,'w');
    if fid==-1
        error(message('hdlcommon:workflow:UnableCreateFile',filePath));
    end

    cd(currentDir);

end