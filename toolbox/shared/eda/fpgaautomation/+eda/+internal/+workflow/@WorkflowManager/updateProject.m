function status=updateProject(h)




    status=0;

    fpgaObj=h.mAutoInterfaceObj;
    hdlcData=h.mWorkflowInfo.hdlcData;
    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;


    hdldisp('Updating generated files in associated ISE project');


    hdlcFullDir=h.getHdlFullDir;
    genFiles=h.getGenFilePath(hdlcFullDir,hdlcData.hdlFiles);

    if~isempty(tdkParam.tdkFiles)
        genFiles=[genFiles...
        ,h.getGenFilePath(hdlcFullDir,tdkParam.tdkFiles)];
    end


    projParts=h.getProjectParts(userParam.assocProjPath);
    assocInfo=h.readAssocInfo(projParts.loc,projParts.name);


    [~,idx]=setdiff(lower(genFiles),lower(assocInfo.files));
    newFiles=genFiles(idx);

    outdatedFiles=setdiff(lower(assocInfo.files),lower(genFiles));

    [~,idx]=intersect(lower(assocInfo.files),lower(genFiles));
    commonFiles=genFiles(idx);


    orgDir=pwd;
    cd(projParts.loc);

    try




        [~,tclStr]=fpgaObj.openProject(projParts.file);


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


        [~,cmd]=fpgaObj.closeProject;
        tclStr=[tclStr,cmd];


        tclFile=tdkParam.tclCmdFile;
        tclErrMsg='Failed to open and read associated project.';
        h.writeTclScript(tclFile,tclStr,tclErrMsg);


        xtclRtn=h.executeTclScript(tclFile,tclErrMsg);


        [targetDevice,projSrcFiles]=h.importProjectSettings(outFile,tclErrMsg);








        filesToRemove={};
        filesToAdd=newFiles;

        if~isempty(projSrcFiles)


            for n=1:length(outdatedFiles)

                idx=strcmpi(outdatedFiles{n},projSrcFiles);
                idx=find(idx,1);
                if~isempty(idx)


                    filesToRemove{end+1}=projSrcFiles{idx};
                end
            end


            for n=1:length(commonFiles)

                idx=strcmpi(commonFiles{n},projSrcFiles);
                idx=find(idx,1);
                if isempty(idx)

                    filesToAdd{end+1}=commonFiles{n};
                end
            end
        else

            filesToAdd=[filesToAdd,commonFiles];
        end





        [statusStr,tclStr]=fpgaObj.openProject(projParts.file,...
        userParam.assocProjPath);


        if~isempty(filesToRemove)
            [stat,cmd]=fpgaObj.removeFiles(filesToRemove);

            tclStr=[tclStr,cmd];
            statusStr=[statusStr,formatDispStr('Removed outdated generated files:',2),stat];
        end


        if~isempty(filesToAdd)
            [stat,cmd]=fpgaObj.addFiles(filesToAdd);

            tclStr=[tclStr,cmd];
            statusStr=[statusStr,formatDispStr('Added latest generated files:',2),stat];
        end


        [stat,cmd]=fpgaObj.closeProject;

        tclStr=[tclStr,cmd];
        statusStr=[statusStr,stat];


        if isempty(filesToRemove)&&isempty(filesToAdd)
            statusStr=[statusStr,formatDispStr('Generated files are up-to-date.',2)];
            xtclRtn='';
        else

            tclFile=tdkParam.tclCmdFile;
            tclErrMsg='Failed to update generated files in project.';
            h.writeTclScript(tclFile,tclStr,tclErrMsg);


            xtclRtn=h.executeTclScript(tclFile,tclErrMsg);
        end


        h.writeAssocInfo(projParts.name,genFiles);



        disp(statusStr);
        if~isempty(xtclRtn)
            hdldisp(['ISE messages:',char(10),xtclRtn]);
        end

        if userParam.importSettings


            [~,idx]=setdiff(lower(projSrcFiles),lower(assocInfo.files));
            userFiles=projSrcFiles(idx);


            hdldisp('Current ISE project settings:');
            hdldisp('   Target device:');
            hdldisp(['      ',targetDevice.family,' ',targetDevice.device...
            ,targetDevice.speed,targetDevice.package]);
            hdldisp('   User source files:');
            if isempty(userFiles)
                hdldisp('      None');
            else
                for n=1:length(userFiles)
                    hdldisp(['      ',userFiles{n}]);
                end
            end


            h.mWorkflowInfo.userParam.projectTarget.family=targetDevice.family;
            h.mWorkflowInfo.userParam.projectTarget.device=targetDevice.device;
            h.mWorkflowInfo.userParam.projectTarget.speed=targetDevice.speed;
            h.mWorkflowInfo.userParam.projectTarget.package=targetDevice.package;

            if isempty(userFiles)
                h.mWorkflowInfo.userParam.projectUserFiles='';
            else
                f=getProjFilePath(userFiles);
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
