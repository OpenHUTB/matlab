classdef Manager<handle








    properties(SetAccess='private',GetAccess='public')
Target
        LocalData=false
    end

    properties(SetAccess='private',GetAccess='private')
RunQueue
DataDir
    end

    methods(Access=public)
        function obj=Manager(tg)
            narginchk(0,1);
            if nargin==0
                obj.LocalData=true;
            elseif nargin==1
                obj.Target=tg;
                obj.LocalData=false;
            end
        end

        function fetchData(obj,requestedRuns)


            if obj.LocalData==true
                error(message('slrealtime:logging:LoggingManagerUsage'));
            end


            newRuns=obj.moveLogData(requestedRuns);

            obj.RunQueue=slrealtime.internal.logging.Manager.formatTable([obj.RunQueue;newRuns]);
        end

        function addLocalData(obj,requestedRuns)
            if obj.LocalData==false
                error(message('slrealtime:logging:LoggingManagerUsage'));
            end

            obj.RunQueue=slrealtime.internal.logging.Manager.formatTable([obj.RunQueue;requestedRuns]);
        end

        function s=getQueueDataSize(obj)

            s=0;
            if~isempty(obj.RunQueue)
                s=sum(obj.RunQueue.Size);
            end
        end

        function fileLogRun=front(obj)

            fileLogRun=obj.RunQueue(1,:);
        end


        function remove(obj,rn)
            [~,row,~]=intersect(obj.RunQueue,rn,'rows');

            obj.runDestructor(obj.RunQueue(row,:));

            obj.RunQueue(row,:)=[];
        end


        function b=complete(obj)
            b=isempty(obj.RunQueue);
        end

        function rq=getRunQueue(obj)
            rq=obj.RunQueue;
        end
    end

    methods(Access=private)

        function movedRuns=moveLogData(obj,runTable)

            movedRuns=table;


            if isempty(obj.DataDir)
                obj.DataDir=tempname;
                mkdir(obj.DataDir);
            end

            currDir=pwd;
            Cleanup=onCleanup(@()cd(currDir));

            for i=1:height(runTable)
                cd(obj.DataDir);
                rn=runTable(i,:);

                if~isfolder(rn.Application)
                    mkdir(rn.Application);
                end
                cd(rn.Application);

                sparts=strsplit(rn.TargetDir,"/");
                folder=sparts(end);
                if isfolder(folder)


                    dupRunFolder=tempname(folder);
                    mkdir(dupRunFolder);
                    cd(dupRunFolder);
                end


                if slrealtime.internal.logging.Manager.isActive(obj.Target,rn)
                    try
                        obj.Target.FileLog.disableLogging();
                    catch ME


                    end
                end

                obj.Target.copyfolder(rn.TargetDir);

                if slrealtime.internal.logging.hasLogDataOnRAM(obj.Target,rn.TargetDir)
                    locCopyRAMFiles(obj.Target,folder);
                end





                rn.HostDir=fullfile(pwd,filesep,folder);
                movedRuns=[movedRuns;rn];%#ok<AGROW>
            end
        end


        function runDestructor(obj,rn)

            if~obj.LocalData

                slrealtime.internal.logging.Manager.deleteRun(obj.Target,rn,false);

                if slrealtime.internal.logging.Manager.isActive(obj.Target,rn)
                    try
                        obj.Target.FileLog.enableLogging();
                    catch ME


                    end
                end
            end
        end

    end

    methods
        function delete(obj)
            if~isempty(obj.DataDir)&&isfolder(obj.DataDir)
                rmdir(obj.DataDir,'s');
                obj.DataDir=[];
            end
        end
    end

    methods(Static=true)

        function b=isActive(tg,rn)
            b=false;
            if any(contains(rn.Properties.VariableNames,'Active'))&&rn.Active





                [running,appName]=tg.isRunning();
                if running&&strcmp(appName,rn.Application)
                    b=true;
                end
            end
        end

        function tb=formatTable(tb)
            tb=unique(tb);

            tb=sortrows(tb,{'Application','StartDate'});
        end


        function deleteRun(tg,rn,deleteTargetRun)

            if any(contains(rn.Properties.VariableNames,'HostDir'))
                rmdir(rn.HostDir,'s');
            end


            if slrealtime.internal.logging.hasLogDataOnRAM(tg,rn.TargetDir)
                slrealtime.internal.logging.deleteLogDataOnRAM(tg);
            end





            if deleteTargetRun
                tg.cleanfolder(rn.TargetDir);
            end
        end

    end

end


function locCopyRAMFiles(tg,relativePath)
    currDir=pwd;
    Cleanup=onCleanup(@()cd(currDir));
    cd(relativePath);
    res=tg.executeCommand("ls /dev/shmem/BufferedLogging_*");
    if~isempty(res.Output)
        res=split(res.Output);
        files=res(~cellfun('isempty',res));
        for i=1:numel(files)

            [~,file,ext]=fileparts(files{i});
            dstFile=extractAfter([file,ext],'BufferedLogging_');
            tg.receiveFile(files{i},dstFile);
        end
    end
end

