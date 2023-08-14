function isNew=sync(modelH)



    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:licenseCheckoutFailed'));
    end

    isNew=false;


    if rmisync.syncTestMode()
        testing=true;
    else
        testing=false;
        rmicom.actxinit();
    end

    [capture,dirName]=rmisync.syncTestCapture();
    if capture
        modelPath=get_param(modelH,'FileName');
        [~,modelName,mdlExt]=rmisl.modelFileParts(modelH);
        newFileName=fullfile(dirName,[modelName,mdlExt]);
        copyfile(modelPath,newFileName);
    end


    if testing
        surrCellArray=rmisync.syncTestModule(modelH);
        reqSettings=rmisl.model_settings(modelH,'get');
        modIdStr=reqSettings.doors.surrogateId;

    else

        if rmidoors.isAppRunning('synchronization')

            hDOORS=rmidoors.comApp();
            if isempty(hDOORS)
                error(message('Slvnv:rmi:sync_with_doors:CommunicationFailed'));
            end

            rmidoors.getModulePrefix([]);

            [modIdStr,isNew]=doorsSurrogateModule(modelH,hDOORS);
            if isempty(modIdStr)
                return;
            end

            if~isNew
                surrCellArray=doorsExtractModule(modIdStr,hDOORS,modelH);
            else
                surrCellArray={};
            end
        else
            return;
        end
    end


    reqSettings=rmisl.model_settings(modelH,'get');


    syncObj=rmidoors.SyncApiDoors(modelH,reqSettings.doors);


    syncObj.isTesting=rmisync.syncTestMode();


    rmisync.updateSurrogateModule(syncObj,surrCellArray);

    if~testing
        modulePath=rmidoors.getModuleAttribute(modIdStr,'FullName');
        if ispc()
            reqmgt('winFocus',[modulePath,'.*']);
        end
    end

    if capture
        newFileName=fullfile(dirName,[modelName,'_post_sync.mdl']);
        save_system(modelH,newFileName);
    end
end


function[modIdStr,isNew]=doorsSurrogateModule(modelH,hDOORS)

    modIdStr=[];
    isNew=false;


    modelName=get_param(modelH,'Name');
    reqSettings=rmisl.model_settings(modelH,'get');
    if isempty(reqSettings.doors.surrogateId)
        prevSyncPath='';
    else
        modIdStr=reqSettings.doors.surrogateId;
        if~isempty(modIdStr)
            try
                prevSyncPath=rmidoors.getModuleAttribute(modIdStr,'FullName');
            catch Mex %#ok<NASGU>
                prevSyncPath='';
            end
        else
            prevSyncPath='';
        end
    end


    moduleDesPath=strrep(strtrim(reqSettings.doors.surrogatepath),'$ModelName$',modelName);
    if strncmp(moduleDesPath,'./',2)
        moduleDesPath(1:2)=[];
        hasRelativePath=true;
    else
        hasRelativePath=(moduleDesPath(1)~='/');
    end


    if hasRelativePath

        currentProj=rmidoors.currentProject(hDOORS);
        if isempty(currentProj)
            errordlg(getString(message('Slvnv:rmi:sync_with_doors:RelativePathNoProject',moduleDesPath)),...
            getString(message('Slvnv:rmi:sync_with_doors:NoOpenProject')));
            modIdStr=[];
            return;
        else


            targetPath=rmidoors.resolveRelPath(moduleDesPath,hDOORS);
        end
    else
        targetPath=moduleDesPath;
    end

    if~isempty(prevSyncPath)


        if~strcmp(targetPath,prevSyncPath)

            msg={getString(message('Slvnv:rmi:sync_with_doors:ModelWasSyncronizedWith',modelName,prevSyncPath)),...
            '',...
            getString(message('Slvnv:rmi:sync_with_doors:SpecifiedModuleIs',targetPath)),...
            '',...
            getString(message('Slvnv:rmi:sync_with_doors:DoYouWantToReuse'))};

            response=questdlg(msg,getString(message('Slvnv:rmi:sync_with_doors:SurrogateMismatch')),...
            getString(message('Slvnv:rmi:sync_with_doors:Reuse')),...
            getString(message('Slvnv:rmi:sync_with_doors:Continue')),...
            getString(message('Slvnv:rmi:sync_with_doors:Cancel')),...
            getString(message('Slvnv:rmi:sync_with_doors:Reuse')));

            if isempty(response)
                response=getString(message('Slvnv:rmi:sync_with_doors:Cancel'));
            end

            switch(response)

            case getString(message('Slvnv:rmi:sync_with_doors:Reuse'))

                reqSettings.doors.surrogatepath=prevSyncPath;
                rmisl.model_settings(modelH,'set',reqSettings);

            case getString(message('Slvnv:rmi:sync_with_doors:Continue'))



                if~isempty(targetPath)


                    rmidoors.invoke(hDOORS,['dmiModuleResolvePath_("',targetPath,'")']);
                    modIdStr=hDOORS.Result;
                    if isempty(modIdStr)
                        modIdStr=createDoorsModule(targetPath,modelName,hDOORS);
                        isNew=true;
                    end


                    try
                        moduleActPath=rmidoors.getModuleAttribute(modIdStr,'FullName');
                        reqSettings.doors.surrogatepath=moduleActPath;
                        reqSettings.doors.surrogateId=modIdStr;
                        rmisl.model_settings(modelH,'set',reqSettings);
                    catch ME %#ok<NASGU>







                        errordlg({getString(message('Slvnv:rmi:sync_with_doors:SpecifiedModuleDeleted',targetPath)),...
                        '',...
                        getString(message('Slvnv:rmi:sync_with_doors:NeedToPurgeOrRestore'))},...
                        getString(message('Slvnv:rmi:sync_with_doors:DOORSError')));



                        reqSettings.doors.surrogatepath=prevSyncPath;
                        rmisl.model_settings(modelH,'set',reqSettings);
                        modIdStr=[];
                    end
                else
                    warning(message('Slvnv:rmi:sync_with_doors:InvalidModulePath',reqSettings.doors.surrogatepath));


                    reqSettings.doors.surrogatepath=prevSyncPath;
                    rmisl.model_settings(modelH,'set',reqSettings);
                    modIdStr=[];
                end
            case getString(message('Slvnv:rmi:sync_with_doors:Cancel'))


                reqSettings.doors.surrogatepath=prevSyncPath;
                rmisl.model_settings(modelH,'set',reqSettings);
                modIdStr=[];
            end
        else



            if hasRelativePath
                reqSettings.doors.surrogatepath=prevSyncPath;
                rmisl.model_settings(modelH,'set',reqSettings);
            end
        end
    else


        modIdStr=rmidoors.resolveModulePath(targetPath,hDOORS);
        if isempty(modIdStr)
            moduleActPath='';
        else
            try
                moduleActPath=rmidoors.getModuleAttribute(modIdStr,'FullName');
            catch Mex
                warning(message('Slvnv:rmi:sync_with_doors:ResolveDoorsModuleFailed',modIdStr,Mex.message,targetPath));
                moduleActPath='';
            end
        end

        if isempty(moduleActPath)
            modIdStr=createDoorsModule(targetPath,modelName,hDOORS);
            if~isempty(modIdStr)
                moduleActPath=rmidoors.getModuleAttribute(modIdStr,'FullName');
            end
            isNew=true;
        end

        if~isempty(moduleActPath)

            reqSettings.doors.surrogatepath=moduleActPath;
            reqSettings.doors.surrogateId=modIdStr;
            rmisl.model_settings(modelH,'set',reqSettings);
        end
    end
end

function modIdStr=createDoorsModule(moduleDesPath,modelName,hDOORS)
    [projName,folder,desName]=rmidoors.pathParts(moduleDesPath,hDOORS);
    modIdStr=createNewSurrogate(projName,folder,desName,modelName,hDOORS);
end

function modIdStr=createNewSurrogate(projName,folder,myPath,modelName,hDOORS)
    rmidoors.invoke(hDOORS,['dmiCreateNewSurrogate_("',projName,'","',folder,'","',myPath,'","',modelName,'");']);
    modIdStr=hDOORS.Result;
    if contains(modIdStr,'DMI Error')||strcmp(modIdStr,'The specified module exists, but is deleted')
        errordlg(modIdStr,getString(message('Slvnv:rmi:sync_with_doors:DOORSError')));
        modIdStr='';
    end
end

function out=doorsExtractModule(modIdStr,hDOORS,modelH)
    fileName=tempname;
    escFileName=strrep(fileName,'\','\\');
    rmidoors.invoke(hDOORS,['dmiExportModulePart_("',modIdStr,'","',escFileName,'",0,true)']);
    out=reqmgt('csvRead',fileName);


    [capture,dirName]=rmisync.syncTestCapture();
    if capture
        modelName=get_param(modelH,'Name');
        newFileName=fullfile(dirName,[modelName,'_surrogate.csv']);
        copyfile(fileName,newFileName);
        prefix=rmidoors.getModulePrefix(modIdStr);
        if~isempty(prefix)
            prefixFile=fullfile(dirName,[modelName,'_prefix.txt']);
            fid=fopen(prefixFile,'wt');
            fprintf(fid,'%s',prefix);
            fclose(fid);
        end
    end
    delete(fileName);
end


