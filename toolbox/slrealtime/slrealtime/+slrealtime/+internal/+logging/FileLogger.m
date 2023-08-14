classdef FileLogger<handle










    methods(Access={?slrealtime.Target})
        function this=FileLogger(tg)
            this.Target=tg;
            this.BufferedLogger=slrealtime.internal.logging.Importer(tg);
        end
    end
    methods(Access=private)
        function delete(this)
            if~isempty(this.BufferedLogger)
                this.BufferedLogger.close();
            end
        end
    end



    properties(Access=private)
Target
    end

    properties(Hidden=true)
BufferedLogger
    end

    properties(Dependent=true,SetAccess=private)
LoggingService
DataAvailable
    end



    methods(Access=public)

        function import(this,request)






















            narginchk(2,2);

            try
                if~this.Target.isConnected()
                    this.Target.connect();
                end


                if this.Target.get('Recording')&&this.Target.isRunning
                    error(message('slrealtime:logging:CannotImportWhenRecording'));
                end


                runTable=slrealtime.internal.logging.legitimizeRequest(request,'Target',this.Target);




                this.BufferedLogger.fetch(runTable);

                createNewSDIRun=slrealtime.internal.feature('KeepAppDesUIsActiveWhenNotRecording')&&~this.Target.get('Recording');
                if createNewSDIRun
                    modelName=this.Target.get('tc').ModelProperties.Application;
                    targetName=this.Target.TargetSettings.name;



                    this.Target.xcp.stopMeasurement(true);
                    slrealtime.internal.sdi.waitForActiveRunToStop(modelName,targetName);
                end


                this.BufferedLogger.import();

                if createNewSDIRun




                    this.BufferedLogger.close();
                    slrealtime.internal.sdi.waitForActiveRunToStop(modelName,targetName);


                    this.Target.set('CreateSDIRunOnStartRecording',false);
                    this.Target.xcpStartMeasurement(true);
                    slrealtime.internal.sdi.waitForActiveRunToStart(modelName,targetName);
                end

            catch ME
                error(message('slrealtime:logging:CannotImport',ME.message));
            end

        end

        function discard(this,request)


















            narginchk(2,2);

            try
                if~this.Target.isConnected()
                    this.Target.connect();
                end


                runTable=slrealtime.internal.logging.legitimizeRequest(request,'Target',this.Target);

                if any(runTable.Active)

                    this.disableLogging();
                end


                for i=1:height(runTable)
                    rn=runTable(i,:);
                    slrealtime.internal.logging.Manager.deleteRun(this.Target,rn,true);
                end

                if any(runTable.Active)&&this.Target.isRunning

                    this.enableLogging();
                end




                if~this.Target.isRunning()
                    slrealtime.internal.logging.deleteLogDataOnRAM(this.Target);
                end

            catch ME
                error(message('slrealtime:logging:CannotDelete',ME.message));
            end
        end

        function runTable=list(this)





















            narginchk(1,1);

            if~this.Target.isConnected()
                this.Target.connect();
            end

            queuedRuns=this.BufferedLogger.getRunQueue();
            runTable=slrealtime.internal.logging.targetLogData(this.Target);

            if~isempty(runTable)

                runTable=slrealtime.internal.logging.FileLogger.filterHiddenCols(runTable);

                runTable=slrealtime.internal.logging.FileLogger.filterQueuedRuns(runTable,queuedRuns);

                runTable=slrealtime.internal.logging.FileLogger.addRowNames(runTable);
            end

        end
    end

    methods(Access=private)

        function enable(this)

            slrealtime.internal.throw.Error('slrealtime:logging:DeprecationWarning','method enable');
        end

        function disable(this)

            slrealtime.internal.throw.Error('slrealtime:logging:DeprecationWarning','method disable');
        end
    end

    methods(Access=private)

        function enableFileLogLogging(this)











            tgStatus=this.Target.status;
            if~strcmpi(tgStatus,"loaded")&&~strcmpi(tgStatus,"running")

                error(message('slrealtime:logging:NoApplication'));
            end

            tc=this.Target.get('tc');
            if strcmpi(tgStatus,"Running")


                blockToken=strcat(this.Target.appsDirOnTarget,"/",...
                tc.ModelProperties.Application,"/misc/enablefilelog.dat");
                if this.Target.isfile(blockToken)
                    error(message('slrealtime:logging:EnableBlockInModel','''filelog.enable'''));
                end
            end

            if tc.LoggingState~=slrealtime.internal.logging.LoggingState.RUNNING||...
                ~strcmpi(tgStatus,"running")






                tc.loggingCommand('start');
            end

        end

        function disableFileLogLogging(this)











            tgStatus=this.Target.status;
            if~strcmpi(tgStatus,"loaded")&&~strcmpi(tgStatus,"running")

                error(message('slrealtime:logging:NoApplication'));
            end

            tc=this.Target.get('tc');

            if strcmpi(tgStatus,"Running")
                tc=this.Target.get('tc');
                blockToken=strcat(this.Target.appsDirOnTarget,"/",...
                tc.ModelProperties.Application,"/misc/enablefilelog.dat");
                if this.Target.isfile(blockToken)
                    error(message('slrealtime:logging:EnableBlockInModel','''filelog.disable'''));
                end
            end

            if(tc.LoggingConnected&&~isempty(tc.LoggingState)&&...
                tc.LoggingState==slrealtime.internal.logging.LoggingState.RUNNING)...
                ||~strcmpi(tgStatus,"running")




                tc.loggingCommand('stop');

                maxWait=1.0;
                start=tic;
                while tc.LoggingState~=slrealtime.internal.logging.LoggingState.STOPPED
                    pause(0.01);
                    if toc(start)>maxWait
                        break;
                    end
                end
            end
        end

    end




    methods
        function s=get.LoggingService(this)
            tc=this.Target.get('tc');
            if isempty(tc)
                s=slrealtime.internal.logging.LoggingState.STOPPED;
            else
                s=tc.LoggingState;
            end
        end
        function s=get.DataAvailable(this)
            if this.Target.isConnected()
                s=~isempty(slrealtime.internal.logging.targetLogData(this.Target));
            else
                s=false;
            end
        end
    end


    methods(Static=true,Hidden=true)
        function tb=addRowNames(tb)
            names=cell(height(tb),1);
            for i=1:length(names)
                names{i}=[num2str(i),'.'];
            end
            tb.Properties.RowNames=names;
        end

        function tb=filterHiddenCols(tb)
            publicColumns={'Application','StartDate','Size'};
            cols=tb.Properties.VariableNames;
            keep=contains(cols,publicColumns);
            tb=tb(:,keep);
        end

        function tb=filterQueuedRuns(tb,queued)
            if isempty(tb)||isempty(queued)
                return
            end
            [~,rows,~]=intersect(...
            slrealtime.internal.logging.FileLogger.filterHiddenCols(tb),...
            slrealtime.internal.logging.FileLogger.filterHiddenCols(queued),'rows');
            tb(rows,:)=[];
        end
    end


    methods(Hidden=true)
        function clean(this)
            this.BufferedLogger=slrealtime.internal.logging.Importer(this.Target);
        end

        function enableLogging(this)
            this.enableFileLogLogging();
        end

        function disableLogging(this)
            this.disableFileLogLogging();
        end
    end

end
