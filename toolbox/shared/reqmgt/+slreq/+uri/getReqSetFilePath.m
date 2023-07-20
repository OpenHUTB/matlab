




function[reqSetFilePath,fName]=getReqSetFilePath(reqSetName)


    reqSetName=slreq.uri.ensureExtension(reqSetName);



    [fPath,fName,fExt]=fileparts(reqSetName);
    fNameExt=[fName,fExt];

    if isempty(fPath)

        reqSetFilePath=which(fNameExt);
        if isempty(reqSetFilePath)&&rmi.isInstalled()

            projectFolder=rmiprj.currentProject('folder');
            if~isempty(projectFolder)
                reqSetFilePath=fullfile(projectFolder,fNameExt);
            end
        end

        if isempty(reqSetFilePath)
            reqSetFilePath=fullfile(pwd,fNameExt);
        end

    else




        if rmiut.isCompletePath(fPath)
            reqSetFilePath=fullfile(fPath,fNameExt);
        else

            reqSetFilePath=rmiut.simplifypath(fullfile(pwd,reqSetName));
        end
    end
end
