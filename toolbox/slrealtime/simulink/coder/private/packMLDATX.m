function packMLDATX(modelName,mode,BuildInfo)





    try
        switch mode
        case 'before_make'
            buildDir=BuildInfo.getBuildDirList{1};



            try
                testObj=slrealtime.internal.Application();
                testObj.termBuild;
            catch E
                if strcmp(E.identifier,'slrealtime:application:noBuildInProg')

                else
                    rethrow E
                end
            end


            if exist([pwd,filesep,modelName,'.mldatx'],'file')
                delete([pwd,filesep,modelName,'.mldatx']);
            end
            thumbnail_file=[buildDir,filesep,modelName,'.png'];
            preferred_width=300;
            preferred_height=200;
            slCreateThumbnailImage(modelName,thumbnail_file,'Width',preferred_width,'Height',preferred_height);
            slrealtime.internal.createApplication(modelName,[buildDir,filesep,modelName,'.png']);

            appObj=slrealtime.internal.Application(modelName);

            appObj.initBuild;

            if exist(fullfile(pwd,'..',[bdroot,'.mldatx']),'file')
                delete(fullfile(pwd,'..',[bdroot,'.mldatx']));
            end

        case 'exit'
            currentDir=pwd;
            dirStruct=RTW.getBuildDir(modelName);
            workingDir=dirStruct.CodeGenFolder;
            buildDir=dirStruct.BuildDirectory;

            appObj=slrealtime.internal.Application();


            appObj.add(['/bin/',modelName],[buildDir,filesep,modelName]);


            assignin('base','dirStruct',dirStruct);
            save([currentDir,filesep,'RTWDirStruct.mat'],'dirStruct');
            appObj.add(['/host/dmr/','RTWDirStruct.mat'],[currentDir,filesep,'RTWDirStruct.mat']);
            delete([currentDir,filesep,'RTWDirStruct.mat']);
            evalin('base','clear dirStruct');


            sourceFile=fullfile(dirStruct.CodeGenFolder,dirStruct.SharedUtilsTgtDir,'shared_file.dmr');
            targetDir=strrep(dirStruct.SharedUtilsTgtDir,'\','/');
            if exist(sourceFile,'file')
                appObj.add(['/host/dmr/',targetDir,'/shared_file.dmr'],sourceFile);
            end


            sourceFile=fullfile(currentDir,'codedescriptor.dmr');
            if exist(sourceFile,'file')
                appObj.add(['/host/dmr/',strrep(dirStruct.RelativeBuildDir,'\','/'),'/codedescriptor.dmr'],sourceFile);
            end


            sourceFile=fullfile(currentDir,'slrealtime_task_info.m');
            if exist(sourceFile,'file')
                appObj.add('/misc/slrealtime_task_info.m',sourceFile);
            end


            [hasPlaybackBlk,loadedModels]=checkPlayback(modelName);


            if strcmp(get_param(modelName,'LoadExternalInput'),'on')||hasPlaybackBlk
                slrealtime.internal.ExternalInputManager.generateArtifacts(appObj,modelName,buildDir,hasPlaybackBlk);
            end



            close_system(loadedModels,0);


            sourceFile=fullfile(currentDir,'sdiStreamingClients.mat');
            if exist(sourceFile,'file')
                appObj.add('/misc/sdiStreamingClients.mat',sourceFile);
            end


            asap2File=[buildDir,filesep,modelName,'.a2l'];
            if isfile(asap2File)
                appObj.add(['/host/asap2/',modelName,'.a2l'],asap2File);
            end




            fullpathToUtility=which('dds.internal.coder.getXmlFileName');
            if~isempty(fullpathToUtility)
                xmlFileName=dds.internal.coder.getXmlFileName(modelName,BuildInfo);
                if isfile(xmlFileName)
                    appObj.add(['/bin/dds/',xmlFileName],xmlFileName);
                end
            end


            metadata=locGetSignalLogging(modelName);
            slrealtime.internal.serializeMetadata(appObj,metadata,'/signalExport/','signalLogging');


            if isfile(fullfile(currentDir,'loggingdb.json'))
                delete(fullfile(currentDir,'loggingdb.json'));
            end
            logdev=slrealtime.internal.logging.Importer;
            logdev.serializeDatabase(currentDir)
            if isfile(fullfile(currentDir,'loggingdb.json'))
                appObj.add('/logging/loggingdb.json',fullfile(currentDir,'loggingdb.json'));
            end


            sourceFile=fullfile(currentDir,'instrumented','profiling_info.mat');
            if isfile(sourceFile)
                appObj.add('/misc/profiling_info.mat',sourceFile);
            end


            sourceFile=fullfile(buildDir,'taskinfo.mat');
            if isfile(sourceFile)&&exist(sourceFile)
                appObj.add('/misc/taskinfo.mat',sourceFile);
            end


            stoptime=slResolve(get_param(modelName,'StopTime'),modelName);
            loglevel=get_param(modelName,'SLRTLogLevel');
            fileLogMaxRuns=get_param(modelName,'SLRTFileLogMaxRuns');
            if strcmp(get_param(modelName,'SLRTForcePollingMode'),'on')


                pollingThreshold=Inf;
            else

                pollingThreshold=1e-4;
            end

            options=slrealtime.internal.ApplicationOptions(appObj);
            options.set(...
            'stoptime',stoptime,...
            'loglevel',convertCharsToStrings(loglevel),...
            'pollingThreshold',pollingThreshold,...
            'fileLogMaxRuns',fileLogMaxRuns,...
            'overrideBaseRatePeriod',0.,...
            'startupParameterSet',convertCharsToStrings('paramInfo'));

            addEnableLogToken(appObj,modelName);


            appInfoFile=fullfile(buildDir,'slrtappartifacts.mat');
            addArtifactsFromList(appInfoFile,appObj);




            refMdls=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            refMdls=setdiff(refMdls,modelName);
            for i=1:length(refMdls)

                appInfoFile=fullfile(dirStruct.CodeGenFolder,...
                dirStruct.ModelRefRelativeRootTgtDir,...
                refMdls{i},...
                'slrtappartifacts.mat');
                addArtifactsFromList(appInfoFile,appObj);


                sourceFile=fullfile(dirStruct.CodeGenFolder,dirStruct.ModelRefRelativeRootTgtDir,refMdls{i},'codedescriptor.dmr');
                if exist(sourceFile,'file')
                    appObj.add(['/host/dmr/',strrep(dirStruct.ModelRefRelativeRootTgtDir,'\','/'),'/',refMdls{i},'/codedescriptor.dmr'],sourceFile);
                end
            end


            metadata=locGetModelDescriptionData(modelName);
            slrealtime.internal.serializeMetadata(appObj,metadata,'/misc/','modelDescription');


            fmuDir=fullfile(buildDir,'fmu');
            if exist(fmuDir,'dir')
                files=dir(fmuDir);
                files={files.name};
                files(1)=[];
                files(1)=[];
                for k=1:length(files)
                    appObj.add(['/bin/fmu/',files{k}],fullfile(fmuDir,files{k}));
                end
            end


            paramInfo=slrealtime.internal.paramSet.parameterInfo(modelName);
            paramInfo.addArtifactToApplication(appObj);


            copyfile(appObj.File,workingDir,'f');
            delete(appObj.File);
            disp(['### Created MLDATX ..\',modelName,'.mldatx']);


            appObj.termBuild;

        case 'error'
            objCleanup(modelName);
        end
    catch E
        objCleanup(modelName);
        rethrow(E);
    end


    function[hasPlayback,loadedModels]=checkPlayback(modelName)


        [refModels,~]=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',true,'IncludeCommented',false);
        loadedModels={};
        searchOption=Simulink.FindOptions('IncludeCommented',false);
        for j=1:length(refModels)
            refModel=refModels{j};
            if~bdIsLoaded(refModel)
                load_system(refModel)
                loadedModels=[loadedModels;refModels{j}];%#ok<AGROW>
            end
            playbackBlks{j}=Simulink.findBlocksOfType(refModel,'Playback',searchOption);%#ok<AGROW>
            if~isempty(playbackBlks{j})
                hasPlayback=true;
                break;
            else
                hasPlayback=false;
            end
        end


        function addArtifactsFromList(appInfoFile,appObj)
            if exist(appInfoFile,'file')
                variableInfo=who('-file',appInfoFile);
                if ismember('appArtifactsToAdd',variableInfo)
                    load(appInfoFile,'appArtifactsToAdd');
                    for i=1:size(appArtifactsToAdd,1)





                        if~isfile(appArtifactsToAdd{i,2})




                            [filePath,fileName,fileExt]=fileparts(appArtifactsToAdd{i,2});
                            [~,modelName,~]=fileparts(filePath);
                            CodeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
                            locFileToAdd=fullfile(CodeGenFolder,'slprj','slrealtime',modelName,[fileName,fileExt]);
                            if isfile(locFileToAdd)
                                appArtifactsToAdd{i,2}=locFileToAdd;
                            end
                        end

                        appObj.add(appArtifactsToAdd{i,1},appArtifactsToAdd{i,2});
                    end
                end
            end

            function objCleanup(modelName)


                if~exist('appObj','var')
                    appObj=slrealtime.internal.Application();
                end
                if appObj.isBuildInit
                    appObj.termBuild;
                end
                delete(appObj);

                if exist([modelName,'.mldatx'],'file')
                    delete([modelName,'.mldatx']);
                end

                function addEnableLogToken(appObj,modelName)





                    if slrealtime.internal.utils.systemhasblocks(modelName,'slrealtimeenablelogging',1)


                        f=fopen(fullfile(appObj.getWorkingDir,'enablefilelog.dat'),'w');
                        fclose(f);
                        appObj.add('/misc/enablefilelog.dat',fullfile(appObj.getWorkingDir,'enablefilelog.dat'));
                    end

                    function metadata=locGetModelDescriptionData(model)
                        metadata.ModelName=model;
                        metadata.ModelVersion=get_param(model,'ModelVersion');

                        dstr=get_param(model,'Created');
                        try


                            dt=datetime(dstr,'InputFormat','eee MMM dd HH:mm:ss yyyy','Locale','en');
                            dt.Format='yyyy-MM-dd HH:mm:ss';
                            metadata.ModelCreationDate=char(dt);
                        catch


                            metadata.ModelCreationDate=dstr;
                        end

                        dstr=get_param(model,"LastModifiedDate");
                        try
                            dt=datetime(dstr,'InputFormat','eee MMM dd HH:mm:ss yyyy','Locale','en');
                            dt.Format='yyyy-MM-dd HH:mm:ss';
                            metadata.ModelLastModifiedDate=char(dt);
                        catch
                            metadata.ModelLastModifiedDate=dstr;
                        end

                        metadata.ModelLastModifiedBy=get_param(model,'LastModifiedBy');
                        metadata.ModelSolverType=get_param(model,'SolverType');
                        metadata.ModelSolverName=get_param(model,'SolverName');

                        appObj=slrealtime.internal.Application();
                        app=dir(appObj.File);
                        try

                            dt=datetime(app.datenum,'ConvertFrom','datenum');
                            dt.Format='yyyy-MM-dd HH:mm:ss';
                            metadata.ApplicationCreationDate=char(dt);
                        catch


                            metadata.ApplicationCreationDate=app.date;
                        end

                        metadata.MatlabVersion=version;

                        info=slrealtime.Target.getSoftwareInfo();
                        checksumInfo=[];
                        checksumInfo.ImageFile=info.ImageFile.host.chksumValue;
                        checksumInfo.QNXTarFile=info.QNXTarFile.host.chksumValue;
                        checksumInfo.SlrtTarFile=info.SlrtTarFile.host.chksumValue;
                        checksumInfo.SpeedgoatLibraryFiles={};
                        if~isempty(info.SpeedgoatLibraryFiles)
                            for i=1:length(info.SpeedgoatLibraryFiles)
                                checksumInfo.SpeedgoatLibraryFiles{i}=info.SpeedgoatLibraryFiles(i).host.chksumValue;
                            end
                            checksumInfo.SpeedgoatLibraryFiles{i+1}=0;
                        end
                        metadata.ChecksumInfo=checksumInfo;

                        function metadata=locGetSignalLogging(modelName)
                            metadata.SignalLogging=get_param(modelName,'SignalLogging');
                            metadata.SignalLoggingName=get_param(modelName,'SignalLoggingName');



