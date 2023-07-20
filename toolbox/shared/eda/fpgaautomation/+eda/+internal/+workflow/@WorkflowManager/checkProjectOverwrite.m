function success=checkProjectOverwrite(h,continueOnWarn)





    success=1;

    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;


    projExist={};
    noProjDir=false;
    if exist(userParam.projectLoc,'dir')
        orgDir=pwd;




        try
            cd(userParam.projectLoc);
        catch me
            noProjDir=true;
            cd(orgDir);
        end

        if~noProjDir
            try

                projPath=h.getProjectPath(userParam.projectLoc,...
                userParam.projectName,tdkParam.projectExt);
                if exist(projPath.fileName,'file')
                    projExist={projPath.filePath};
                end


                projPath=h.getProjectPath(userParam.projectLoc,...
                userParam.projectName,tdkParam.projectOldExt);
                if exist(projPath.fileName,'file')
                    projExist{end+1}=projPath.filePath;
                end

                cd(orgDir);
            catch me
                cd(orgDir);
                rethrow(me);
            end
        end
    end

    if~isempty(projExist)

        printPathS='';
        printPath='';
        for n=1:length(projExist)
            printPathS=[printPathS,blanks(3),projExist{n},char(10)];
            projExist{n}=strrep(projExist{n},'\','\\');
            projExist{n}=strrep(projExist{n},'%','%%');
            printPath=[printPath,blanks(3),projExist{n},char(10)];
        end



        if~continueOnWarn
            msg=[char(10),'The following project already exists:',char(10)...
            ,printPath,char(10)...
            ,'Overwrite existing project? [y]/n '];
            if strcmpi(input(msg,'s'),'n')
                success=0;
                disp(' ');
                dispFpgaMsg('ISE project not created.');
                disp(' ');
                return;
            end
        end

        disp(' ');
        warning(message('EDALink:WorkflowManager:checkProjectOverwrite:overwriteproject',printPathS));


        if h.isIseRunning

            disp(' ');
            msg=['ISE is running. If the project to be overwritten '...
            ,'is currently opened, it may not be created properly.'];
            warning(message('EDALink:WorkflowManager:checkProjectOverwrite:iserunning',msg));


            if~continueOnWarn
                msg=[char(10),'Make sure the following project is closed.'...
                ,char(10),printPath,char(10)...
                ,'Continue? [y]/n '];
                if strcmpi(input(msg,'s'),'n')
                    success=0;
                    disp(' ');
                    dispFpgaMsg('ISE project not created.');
                    disp(' ');
                    return;
                end
            end
        end
    end

