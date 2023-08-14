classdef StreamingProfilerAppSvc<coder.internal.connectivity.TgtConnAppSvc






    properties(Access=public)
        topModelName;
    end



    methods
        function obj=StreamingProfilerAppSvc()
            [mdl,~]=...
            coder.internal.connectivity.TgtConnMgr.getTopModelAndBuildArgs();
            obj.topModelName=mdl;
        end
    end

    methods(Access=public)
        function setupBeforeTLC(obj,mdl)%#ok
        end

        function cleanupAfterTLC(obj,mdl)%#ok
        end

        function codeStr=getIncludesAndDefinesCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getBackgroundTaskCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getMdlInitCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getMdlTermCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getPreStepCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getPostStepCode(obj)%#ok
            codeStr='';
        end
    end

    methods(Access=public)
        function res=isNeeded(obj)
            import coder.internal.connectivity.*
            [mdl,buildArgs]=TgtConnMgr.getTopModelAndBuildArgs();%#ok<ASGLU> 
            mdlRef=~strcmp(buildArgs.ModelReferenceTargetType,'NONE');
            res=~mdlRef&&...
            StreamingProfilerBaseSvc.isStreamingProfilerAppSvcNeeded(...
            obj.topModelName);
        end
        function start(obj,argMap)%#ok
            import coder.internal.connectivity.*
            mdl=obj.topModelName;
            hCS=getActiveConfigSet(mdl);
            if~codertarget.target.isCoderTarget(hCS),return;end
            probes=StreamingProfilerBaseSvc.getTaskProbes(mdl);
            if isempty(probes),return;end
            cores=StreamingProfilerBaseSvc.getTaskCores(mdl);
            probes=StreamingProfilerBaseSvc.updateProbeNames(mdl,probes);
            tasks=StreamingProfilerBaseSvc.createTaskArray(mdl,probes);
            iStartAppService(obj,mdl,tasks,cores);

            function iStartAppService(obj,mdl,tasks,cores)
                logData=true;
                coreLabels=soc.internal.getCoreLabels(obj.topModelName,cores);
                coder.internal.connectivity.ConnectStreamingProfilerAppSvc(...
                obj.tgtConnMgr.getTargetConnection(),mdl,uint32(cores),tasks,...
                StreamingProfilerBaseSvc.getProfileTimerResolution(mdl),...
                logData,false,coreLabels);
            end
        end
        function stop(obj)
            postfix=DAStudio.message('soc:scheduler:HWDiagFolderPostfix');
            soc.internal.profile.saveTaskInfo(obj.topModelName,postfix);
        end
    end
end
