classdef PctManager<handle

    properties(SetAccess=private)
simJob
cluster
futures
pool
        numtasks=0;
        usePool=false;
    end
    methods
        function mgr=PctManager(clusterName)

            if nargin>0
                mgr.cluster=parcluster(clusterName);
            else
                mgr.cluster=parcluster;
            end
            if mgr.isLocal
                mgr.pool=gcp('nocreate');
                if isempty(mgr.pool)
                    mgr.pool=mgr.cluster.parpool;
                else
                    mgr.cluster=mgr.pool.Cluster;
                end
                mgr.usePool=true;
                mgr.futures=parallel.FevalFuture.empty;
            end
        end
        function createJob(mgr)
            if~mgr.usePool&&isempty(mgr.simJob)
                mgr.simJob=createJob(mgr.cluster);
            end
        end
        function addScriptToJob(mgr,script)
            mgr.createJob
            script=string(script);
            if mgr.usePool
                mgr.numtasks=mgr.numtasks+1;
                mgr.futures(mgr.numtasks)=parfeval(@runSimulationScript,0,script);
            else
                task=createTask(mgr.simJob,@runSimulationScript,0,{script});
                task.NumOutputArguments=1;
            end
        end
        function job=run(mgr)
            if~mgr.usePool
                if~isempty(mgr.simJob)
                    mgr.simJob.AutoAttachFiles=true;
                    submit(mgr.simJob)
                end
            end
            if nargout>0
                job=mgr.simJob;
            end
        end
        function cancelJob(mgr)
            if~isempty(mgr.simJob)
                cancel(mgr.simJob);
            end
            if mgr.usePool
                if~isempty(mgr.futures)
                    mgr.futures.cancel
                end
            end
        end
        function numWorkers=getNumWorkers(mgr)
            numWorkers=int32(mgr.cluster.NumWorkers);
        end
        function osName=getOS(mgr)
            os=string(mgr.cluster.OperatingSystem);
            osName=os;
        end
        function mwRoot=getClusterMatlabRoot(mgr)
            mwr=string(mgr.cluster.ClusterMatlabRoot);
            mwRoot=mwr;
        end
        function isLocal=isLocal(mgr)
            isLocal=strcmpi(mgr.cluster.Type,'local');
        end
        function isHPC=isHPC(mgr)
            isHPC=strcmpi(mgr.cluster.Type,'HPCServer');
        end
        function clusterInfo=clusterInfo(mgr)


            clusterInfo=string.empty;
            clusterInfo(end+1)="Profile";
            clusterInfo(end+1)=string(mgr.cluster.Profile);
            clusterInfo(end+1)="Type";
            clusterInfo(end+1)=string(mgr.cluster.Type);
            clusterInfo(end+1)="Host";
            clusterInfo(end+1)=string(mgr.cluster.Host);
            clusterInfo(end+1)="NumThreads";
            clusterInfo(end+1)=string(mgr.cluster.NumThreads);
            clusterInfo(end+1)="NumWorkers";
            clusterInfo(end+1)=string(mgr.cluster.NumWorkers);
            clusterInfo(end+1)="OperatingSystem";
            clusterInfo(end+1)=string(mgr.cluster.OperatingSystem);
        end
        function poolInfo=poolInfo(mgr)


            poolInfo=string.empty;
            if~mgr.usePool
                return
            end
            poolInfo(end+1)="Cluster";
            poolInfo(end+1)=string(mgr.pool.Cluster.Profile);
            poolInfo(end+1)="Connected";
            poolInfo(end+1)=string(mgr.pool.Connected);
            poolInfo(end+1)="NumWorkers";
            poolInfo(end+1)=string(mgr.pool.NumWorkers);
            poolInfo(end+1)="IdleTimeout";
            poolInfo(end+1)=string(mgr.pool.IdleTimeout);
        end
    end
    methods(Static)
        function clusters=definedClusters
            cmd=which('parallel.listProfiles');
            if~isempty(cmd)
                clusters=string(parallel.listProfiles);
            else
                clusters="";
            end
        end
        function cluster=defaultCluster
            cmd=which('parallel.defaultProfile');
            if~isempty(cmd)
                cluster=string(parallel.defaultProfile);
            else
                cluster="";
            end
        end
        function clusterType=Type(clusterName)
            cmd=which('parcluster');
            if~isempty(cmd)
                clusterType=string(parcluster(clusterName).Type);
            else
                clusterType="";
            end
        end
    end
end


