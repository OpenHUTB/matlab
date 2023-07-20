function folderName=getReqSetTempDir(reqSetName)


    dirBaseName=slreq.opc.getReqSetDirBaseName(reqSetName);
    folderName=fullfile(slreq.opc.getUsrTempDir,dirBaseName);

    if exist(folderName,'file')~=7
        mkdir(folderName);
    end

    folderName=strrep(folderName,'\','/');
end