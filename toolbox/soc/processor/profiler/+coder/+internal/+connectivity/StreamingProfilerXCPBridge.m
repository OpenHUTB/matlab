classdef StreamingProfilerXCPBridge


    methods(Static)
        function connect(obj,mdl)
            import coder.internal.connectivity.*
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
                coder.internal.connectivity.ConnectStreamingProfilerXCPBridge(...
                obj,mdl,uint32(cores),tasks,...
                StreamingProfilerBaseSvc.getProfileTimerResolution(mdl),...
                logData,false);
            end
        end
        function stop(mdl)
            postfix=DAStudio.message('soc:scheduler:HWDiagFolderPostfix');
            soc.internal.profile.saveTaskInfo(mdl,postfix)
        end
    end
end
