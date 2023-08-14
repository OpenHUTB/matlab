classdef Importer<handle








    properties(GetAccess=private,SetAccess=private)
CustomListener
ImportManager
Logger
Target

        SDITargetName=''

LastRun
CurrentRun
CodeDescDir
SlrealtimeApp
        Fetching=false
    end

    properties(GetAccess=public,SetAccess=private)
        SDIRunId=0
    end


    methods(Access=public)
        function obj=Importer(tg)
            narginchk(0,1)
            if nargin>0
                obj.Target=tg;
            else

                obj.SDITargetName='LocalHost [FileLog]';
            end
        end

        function import(obj)

            obj.doImport();
        end

        function fetch(obj,runTable)
            obj.Fetching=true;
            if(isempty(obj.ImportManager))
                obj.ImportManager=slrealtime.internal.logging.Manager(obj.Target);
            end


            obj.ImportManager.fetchData(runTable);
            obj.Fetching=false;
        end

        function importLocal(obj,runTable)

            obj.checkFileLogDataVersion(runTable);

            obj.Fetching=true;
            if isempty(obj.ImportManager)
                obj.ImportManager=slrealtime.internal.logging.Manager;
            end
            obj.ImportManager.addLocalData(runTable);
            obj.Fetching=false;


            obj.doImport();
        end

        function serializeDatabase(obj,codeDescDir)

            obj.Logger=slrealtime.internal.logging.Logger(codeDescDir,"","");
            obj.Logger.buildAndSerializeDatabase();
        end

        function rq=getRunQueue(obj)
            if~isempty(obj.ImportManager)
                rq=obj.ImportManager.getRunQueue();
            else
                rq=table();
            end
        end

        function close(obj)
            obj.ImportManager=[];
            obj.LastRun=[];
            obj.CurrentRun=[];
            if(~isempty(obj.Logger))

                obj.Logger.destroyAsyncQueues();
            end
            delete(obj.Logger);
            obj.Logger=[];
        end
    end



    methods(Access=private)
        function createOrUpdateLogger(obj)
            assert(~isempty(obj.ImportManager),'Cannot open channel, import manager empty');
            obj.setCodeDescDir;
            md=obj.modelDesc();
            if isempty(obj.Logger)

                if isempty(obj.SDITargetName)
                    obj.Logger=slrealtime.internal.logging.Logger(obj.CodeDescDir,obj.Target.TargetSettings.name,md.ModelName);
                else
                    obj.Logger=slrealtime.internal.logging.Logger(obj.CodeDescDir,obj.SDITargetName,md.ModelName);
                end
            else
                obj.Logger.BuildDir=obj.CodeDescDir;
                obj.Logger.ModelName=md.ModelName;
            end
        end


        function importDoneCB(obj)

            clObj=slrealtime.internal.logging.cleanupFunction(@()obj.close());


            if isempty(obj.CurrentRun)
                clObj.disableCleanup();
                return;
            end


            obj.ImportManager.remove(obj.CurrentRun);

            obj.LastRun=obj.CurrentRun;
            obj.CurrentRun=[];
            if obj.ImportManager.complete()

                obj.close();
            else

                obj.Logger.destroyAsyncQueues()
                if(obj.SDIRunId~=0)
                    Run=Simulink.sdi.getRun(obj.SDIRunId);

                    waitfor(Run,'Status',DAStudio.message('slrealtime:target:notAvailable'));
                end
                obj.doImport();
            end



            clObj.disableCleanup();
        end

        function doImport(obj)

            clObj=slrealtime.internal.logging.cleanupFunction(@()obj.close());


            obj.CurrentRun=obj.ImportManager.front();
            newSDIRun=true;



            if~isempty(obj.LastRun)
                if obj.CurrentRun.Application==obj.LastRun.Application


                    if obj.CurrentRun.StartDate==obj.LastRun.StartDate&&~obj.ImportManager.LocalData
                        newSDIRun=false;
                    end
                end
            end


            if newSDIRun

                if isempty(obj.Logger)||(obj.CurrentRun.Application~=obj.LastRun.Application)
                    obj.createOrUpdateLogger();
                end


                w1=warning('off','backtrace');
                Cleanup1=onCleanup(@()warning(w1));
                w2=warning('off','SimulinkHMI:errors:ModelAlreadyConfigured');
                Cleanup2=onCleanup(@()warning(w2));
                [oldWarnMsg,oldWarnId]=lastwarn;
                lastwarn('');


                obj.Logger.createAsyncQueues();
                [~,warnId]=lastwarn;
                if~isempty(warnId)&&...
                    strcmp(warnId,'SimulinkHMI:errors:ModelAlreadyConfigured')
                    MSLDiagnostic('SimulinkHMI:errors:ModelAlreadyConfigured',obj.CurrentRun.Application);
                    lastwarn(oldWarnMsg,oldWarnId);
                end
            end
            obj.SDIRunId=obj.updateStream();




            oldval=Simulink.sdi.getRecordData();
            Simulink.sdi.setRecordData(true);
            RecordModeCleanup=onCleanup(@()Simulink.sdi.setRecordData(oldval));


            obj.Logger.importDataToAsyncQueues(obj.CurrentRun.HostDir);


            obj.importDoneCB();


            clObj.disableCleanup();
        end

        function runId=updateStream(obj)
            md=obj.modelDesc();

            if isempty(obj.SDITargetName)
                targetName=obj.Target.TargetSettings.name;
            else
                targetName=obj.SDITargetName;
            end
            runId=slrealtime.internal.sdi.getActiveRunId(md.ModelName,targetName);
            if runId==0
                error(message('slrealtime:logging:NoSdiRunFound'));
            else
                slrealtime.internal.sdi.setRunMetaData(runId,md.ModelName,targetName,md);


                startdate=datetime(obj.CurrentRun.StartDate,'TimeZone','local');
                slrealtime.internal.sdi.start(runId,md.ModelName,targetName,posixtime(startdate));
            end
        end

        function b=appRunning(obj,appsList)
            [running,runningAppName]=obj.Target.isRunning();
            b=false;
            if running&&any(strcmp(runningAppName,appsList))

                b=true;
            end
        end

        function b=targetIsLogging(obj)
            tc=obj.Target.get('tc');
            b=(tc.LoggingState==slrealtime.internal.logging.LoggingState.RUNNING);
        end

        function setCodeDescDir(obj)
            if obj.ImportManager.LocalData


                sparts=strsplit(obj.CurrentRun.HostDir,filesep);

                wd=strjoin(sparts(1:end-2),filesep);
            else
                appName=obj.CurrentRun.Application;
                obj.setSlrealtimeApp(appName);
                wd=obj.SlrealtimeApp.getWorkingDir();
                obj.SlrealtimeApp.extract('/host/dmr/');
            end
            RTWDirStruct=load(fullfile(wd,'host','dmr','RTWDirStruct.mat'));
            obj.CodeDescDir=fullfile(wd,'host','dmr',RTWDirStruct.dirStruct.RelativeBuildDir);
        end

        function setSlrealtimeApp(obj,appName)
            appFile=obj.Target.getAppFile(appName);
            obj.SlrealtimeApp=slrealtime.Application(appFile);
        end

        function md=modelDesc(obj)

            if obj.ImportManager.LocalData

                sparts=strsplit(obj.CurrentRun.HostDir,filesep);

                appDir=strjoin(sparts(1:end-2),filesep);
                str=fileread(fullfile(appDir,'misc','modelDescription.json'));
                metadata=jsondecode(str);
                md=metadata;
            else

                md=obj.SlrealtimeApp.getInformation;
            end
        end

        function checkFileLogDataVersion(obj,runTable)

            [~,indexes,~]=unique(runTable.Application);
            uniqueRunTable=runTable(indexes,:);
            for row=1:height(uniqueRunTable)
                run=uniqueRunTable(row,:);


                stringArray=strsplit(run.HostDir,filesep);
                appFilePath=strjoin(stringArray(1:end-2),filesep);

                appFile=strcat(appFilePath,filesep,run.Application,'.mldatx');
                appObj=slrealtime.Application(appFile);
                appInfo=appObj.getInformation;
                if~strcmp(version,appInfo.MatlabVersion)
                    error(message('slrealtime:logging:localImportVersion',appInfo.MatlabVersion,version));
                end
            end
        end

    end


    methods
        function delete(obj)
            close(obj);
        end
    end
end
