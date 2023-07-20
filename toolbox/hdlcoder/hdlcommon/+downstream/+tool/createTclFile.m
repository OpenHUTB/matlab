function fid=createTclFile(tclFilePath,targetDir)




    if nargin<2
        targetDir=pwd;
    end

    currentDir=pwd;
    cd(targetDir);

    tclFileFolder=fileparts(tclFilePath);
    downstream.tool.createDir(tclFileFolder);

    fid=fopen(tclFilePath,'w');
    if fid==-1
        error(message('hdlcommon:workflow:UnableCreateTclFile',tclFilePath));
    end

    cd(currentDir);

end