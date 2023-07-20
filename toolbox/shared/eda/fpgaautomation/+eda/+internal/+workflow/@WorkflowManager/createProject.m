function status=createProject(h)





    status=0;

    fpgaObj=h.mAutoInterfaceObj;
    hdlcData=h.mWorkflowInfo.hdlcData;
    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;
    control=h.mWorkflowInfo.control;

    hdldisp('Creating new ISE project');


    if control.CheckProjDuringRun
        continueOnWarn=false;
        success=h.checkProjectOverwrite(continueOnWarn);
        if~success
            status=1;
            return;
        end
    end


    hdlcFullDir=h.getHdlFullDir;
    genFiles=h.getGenFilePath(hdlcFullDir,hdlcData.hdlFiles);

    if~isempty(tdkParam.tdkFiles)
        genFiles=[genFiles...
        ,h.getGenFilePath(hdlcFullDir,tdkParam.tdkFiles)];
    end


    if~isempty(userParam.projectUserFiles)
        userFiles=getUserFilePath(userParam.projectUserFiles);
    end


    orgDir=pwd;
    h.makeProjectDir;
    cd(userParam.projectLoc);

    tclStr='';
    statusStr='';
    try

        h.deleteExistingProject;


        projPath=h.getProjectPath(pwd,userParam.projectName,...
        tdkParam.projectExt);
        [stat,cmd]=fpgaObj.newProject(userParam.projectName,...
        userParam.projectLoc,userParam.projectTarget,projPath.filePath);

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,stat];


        [stat,cmd]=fpgaObj.addFiles(genFiles);

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,formatDispStr('Generated files:',2),stat];


        if~isempty(userParam.projectUserFiles)
            [stat,cmd]=fpgaObj.addFiles(userFiles);

            tclStr=[tclStr,cmd];
            statusStr=[statusStr,formatDispStr('User files:',2),stat];
        end


        if~isempty(userParam.projectProperties)
            [stat,cmd]=fpgaObj.setProp(userParam.projectProperties);

            tclStr=[tclStr,cmd];
            statusStr=[statusStr,stat];
        end


        [stat,cmd]=fpgaObj.closeProject;

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,stat];


        tclFile=tdkParam.tclCmdFile;
        tclErrMsg='Project creation failed.';
        h.writeTclScript(tclFile,tclStr,tclErrMsg);


        xtclRtn=h.executeTclScript(tclFile,tclErrMsg);


        if control.AssociateProject

            h.writeAssocInfo(userParam.projectName,genFiles);

            h.mWorkflowInfo.userParam.assocProjPath=projPath.filePath;
            h.mWorkflowInfo.userParam.assocExist=true;
        end


        disp(statusStr);
        if~isempty(xtclRtn)
            hdldisp(['ISE messages:',char(10),xtclRtn]);
        end


        cd(orgDir);

    catch me
        cd(orgDir);
        rethrow(me);
    end



    function filepath=getUserFilePath(filelist)

        for n=1:length(filelist)
            if~exist(filelist{n},'file')
                name=strrep(filelist{n},'%','%%');
                name=strrep(name,'\','\\');
                error(message('EDALink:WorkflowManager:createProject:userfilenotfound',name));
            end

            [fileDir,fileName,fileExt]=fileparts(filelist{n});
            if isempty(fileDir)
                f=fullfile(pwd,[fileName,fileExt]);
            else
                org_dir=pwd;
                cd(fileDir);
                fileDir=pwd;
                cd(org_dir);

                f=fullfile(fileDir,[fileName,fileExt]);
            end

            filepath{n}=strrep(f,'\','/');
        end
