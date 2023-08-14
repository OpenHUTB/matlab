classdef CodeInstrumentationTaskProfiler<soc.profiler.TaskProfilerBase












    properties(Access='private')
ModelName
CfgSet
    end
    properties
        Started=false
    end
    methods
        function h=CodeInstrumentationTaskProfiler(mdlName)

            h.ModelName=mdlName;
        end
        function delete(h)

            if h.Started
                codertarget.targetservices.SDIIntegration.manageInstance('clear',h.ModelName);
                h.Started=false;
            end
        end
        function start(h)
            h.CfgSet=getActiveConfigSet(h.ModelName);
            attr=codertarget.attributes.getTargetHardwareAttributes(h.CfgSet);
            if isfield(attr.Profiler,'StreamingProfilerStartCallback')
                feval(attr.Profiler.StreamingProfilerStartCallback,h.CfgSet);
            end
            codertarget.targetservices.SDIIntegration.manageInstance('clear',h.ModelName);
            obj=codertarget.targetservices.SDIIntegration.manageInstance('get',h.ModelName);
            if~obj.SupportsTargetServices
                DAStudio.error('soc:taskprofiler:UnsupportedConfiguration',h.ModelName);
            end
            success=obj.startSDI;
            if~success
                cgdir=RTW.getBuildDir(h.ModelName);
                DAStudio.error('soc:taskprofiler:UnableToStreamFromTheHardware',cgdir.BuildDirectory);
            else
                h.Started=true;
            end
            hmiOpts.RecordOn=1;
            hmiOpts.VisualizeOn=1;
            hmiOpts.CommandLine=false;
            hmiOpts.StartTime=get_param(h.ModelName,'SimulationTime');
            hmiOpts.StopTime=inf;






            hmiOpts.EnableRollback=slprivate('onoff',get_param(h.ModelName,'EnableRollback'));
            hmiOpts.SnapshotInterval=get_param(h.ModelName,'SnapshotInterval');
            hmiOpts.NumberOfSteps=get_param(h.ModelName,'NumberOfSteps');
            Simulink.HMI.slhmi('sim_start',h.ModelName,hmiOpts);
        end
        function stop(h)
            obj=codertarget.targetservices.SDIIntegration.manageInstance('get',h.ModelName);
            obj.stopSDI;
            h.Started=false;
            if~isempty(h.CfgSet)
                attr=codertarget.attributes.getTargetHardwareAttributes(h.CfgSet);
                if isfield(attr.Profiler,'StreamingProfilerStopCallback')
                    feval(attr.Profiler.StreamingProfilerStopCallback,h.CfgSet);
                end
            end
        end

    end
end