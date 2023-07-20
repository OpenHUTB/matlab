function status=addExistingProject(h)





    status=0;

    fpgaObj=h.mAutoInterfaceObj;
    hdlcData=h.mWorkflowInfo.hdlcData;
    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;
    control=h.mWorkflowInfo.control;


    hdldisp('Adding generated files to existing ISE project');


    if control.CheckProjDuringRun
        continueOnWarn=false;
        success=h.checkOpenedProject(continueOnWarn);
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


    projParts=h.getProjectParts(userParam.existingPath);
    orgDir=pwd;



    if~isempty(projParts.loc)
        cd(projParts.loc);
    end

    tclStr='';
    statusStr='';
    try


        projPath=h.getProjectPath(pwd,projParts.name,projParts.ext);
        [stat,cmd]=fpgaObj.openProject(projParts.file,projPath.filePath);

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,stat];

        if control.AssociateProject&&userParam.importSettings


            outFile=tdkParam.tclOutFile;
            tclVarName='outputfile';
            [~,cmd]=fpgaObj.openFile(outFile,tclVarName);
            tclStr=[tclStr,cmd];


            [~,cmd]=fpgaObj.getTargetDevice(tclVarName);
            tclStr=[tclStr,cmd];



            [~,cmd]=fpgaObj.getProjectFiles(tclVarName);
            tclStr=[tclStr,cmd];



            [~,cmd]=fpgaObj.closeFile(tclVarName);
            tclStr=[tclStr,cmd];

        end


        [stat,cmd]=fpgaObj.addFiles(genFiles);

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,formatDispStr('Added generated files:',2),stat];


        [stat,cmd]=fpgaObj.closeProject;

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,stat];


        tclFile=tdkParam.tclCmdFile;
        tclErrMsg='Failed to add generated files to project.';
        h.writeTclScript(tclFile,tclStr,tclErrMsg);


        xtclRtn=h.executeTclScript(tclFile,tclErrMsg);


        if control.AssociateProject

            h.writeAssocInfo(projParts.name,genFiles);

            h.mWorkflowInfo.userParam.assocProjPath=projPath.filePath;
            h.mWorkflowInfo.userParam.assocExist=true;
        end



        disp(statusStr);
        if~isempty(xtclRtn)
            hdldisp(['ISE messages:',char(10),xtclRtn]);
        end

        if control.AssociateProject&&userParam.importSettings


            errMsg='Failed to read project settings from existing project.';
            [targetDevice,projSrcFiles]=h.importProjectSettings(outFile,errMsg);


            hdldisp('Current ISE project settings:');
            hdldisp('   Target device:');
            hdldisp(['      ',targetDevice.family,' ',targetDevice.device...
            ,targetDevice.speed,targetDevice.package]);
            hdldisp('   User source files:');
            if isempty(projSrcFiles)
                hdldisp('      None');
            else
                for n=1:length(projSrcFiles)
                    hdldisp(['      ',projSrcFiles{n}]);
                end
            end


            h.mWorkflowInfo.userParam.projectTarget.family=targetDevice.family;
            h.mWorkflowInfo.userParam.projectTarget.device=targetDevice.device;
            h.mWorkflowInfo.userParam.projectTarget.speed=targetDevice.speed;
            h.mWorkflowInfo.userParam.projectTarget.package=targetDevice.package;

            if isempty(projSrcFiles)
                h.mWorkflowInfo.userParam.projectUserFiles='';
            else
                f=getProjFilePath(projSrcFiles);
                h.mWorkflowInfo.userParam.projectUserFiles=f;
            end


        end


        cd(orgDir);

    catch me
        cd(orgDir);
        rethrow(me);
    end


    function filepath=getProjFilePath(filelist)



        for n=1:length(filelist)
            filepath{n}=strrep(filelist{n},'/',filesep);
        end
