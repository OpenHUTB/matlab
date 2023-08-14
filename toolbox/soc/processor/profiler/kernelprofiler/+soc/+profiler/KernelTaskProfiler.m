classdef KernelTaskProfiler<soc.profiler.TaskProfilerBase













    properties(Access='private')
ModelName
CfgSet
StartSessionCount
StopSessionCount
    end

    properties
KernelProfilerObj
    end
    methods
        function h=KernelTaskProfiler(mdlName)


            h.StartSessionCount=0;
            h.StopSessionCount=0;

            mdlName=char(mdlName);
            h.ModelName=mdlName;
            boardName=get_param(mdlName,'HardwareBoard');
            hCS=getActiveConfigSet(mdlName);
            numOfCores=codertarget.targethardware.getNumberOfCores(hCS);
            attr=codertarget.attributes.getTargetHardwareAttributes(hCS);h.KernelProfilerObj=soc.profiler.LTTngKernelProfiler;
            h.KernelProfilerObj.NumberOfCores=numOfCores;
            h.KernelProfilerObj.TimerTicksPerSecond=str2double(attr.Profiler.TimerTicksPerS);
            h.KernelProfilerObj.ValidateFcn='soc.profiler.LTTngConfigControl.validate';
            h.KernelProfilerObj.StartFcn='soc.profiler.LTTngConfigControl.start';
            h.KernelProfilerObj.StopFcn='soc.profiler.LTTngConfigControl.stop';
            h.KernelProfilerObj.DestroyFcn='soc.profiler.LTTngConfigControl.destroy';
            h.KernelProfilerObj.ConfigureFcn='soc.profiler.LTTngConfigControl.configure';
            h.KernelProfilerObj.LogDirectory=soc.internal.profile.getDiagnosticDirectory(mdlName);
            ext=codertarget.tools.getApplicationExtension(mdlName);
            h.KernelProfilerObj.ApplicationName=[mdlName,ext];

            if strcmp(h.KernelProfilerObj.KernelLatencyTaskName,'Notspecified')
                h.KernelProfilerObj.KernelLatencyTaskName='scheduler';
            end
            h.KernelProfilerObj.ModelName=mdlName;
            h.CfgSet=getActiveConfigSet(h.ModelName);

            valStore=DAStudio.message('codertarget:ui:HWDiagViewLevelStorage');
            if codertarget.data.isParameterInitialized(h.CfgSet,valStore)
                val=codertarget.data.getParameterValue(h.CfgSet,valStore);
                viewLevel=double(~isequal(val,'Task manager tasks'));
                h.KernelProfilerObj.ViewLevel=viewLevel;
            else
                h.KernelProfilerObj.ViewLevel=0;
            end

            cores=soc.internal.getActiveCoresFromTaskManager(mdlName);
            coreLabels=soc.internal.getCoreLabels(mdlName,cores);
            h.KernelProfilerObj.setActiveCoreSet(uint32(cores),coreLabels);


            if codertarget.profile.internal.isKernelProfilingEnabled(h.CfgSet)
                valStore=DAStudio.message('codertarget:ui:HWDiagRecordingStorage');
                if codertarget.data.isParameterInitialized(h.CfgSet,valStore)&&...
                    isequal(codertarget.data.getParameterValue(...
                    h.CfgSet,valStore),'Continuous')
                    h.KernelProfilerObj.Mode='ONLINE';
                else
                    h.KernelProfilerObj.Mode='OFFLINE';
                end
            else
                h.KernelProfilerObj.Mode='OFFLINE';
            end
            h.KernelProfilerObj.IPAddress=strrep(codertarget.attributes.getExtModeData('IPAddress',h.CfgSet),'''','');
            h.KernelProfilerObj.Port=str2double(codertarget.attributes.getExtModeData('Port',h.CfgSet))+2;
            if codertarget.data.isParameterInitialized(h.CfgSet,'BoardParameters.Username')
                h.KernelProfilerObj.Username=codertarget.data.getParameterValue(h.CfgSet,'BoardParameters.Username');
            else
                h.KernelProfilerObj.Username='root';
            end
            if codertarget.data.isParameterInitialized(h.CfgSet,'BoardParameters.Password')
                h.KernelProfilerObj.Password=codertarget.data.getParameterValue(h.CfgSet,'BoardParameters.Password');
            else
                h.KernelProfilerObj.Password='root';
            end

            h.deleteUnwantedFiles;
        end
        function start(h)
            if h.StartSessionCount==0
                h.KernelProfilerObj.start;

                h.StartSessionCount=1;
                h.StopSessionCount=0;
            else
                DAStudio.error('soc:taskprofiler:KernelProfilerStartError');
            end
        end
        function stop(h)
            if h.StopSessionCount==0&&h.StartSessionCount==1
                h.KernelProfilerObj.stop;

                h.StopSessionCount=1;
                h.StartSessionCount=0;
                if strcmp(h.KernelProfilerObj.Mode,'ONLINE')
                    h.deleteUnwantedFiles;
                end
            else
                DAStudio.error('soc:taskprofiler:KernelProfilerStopError');
            end

        end
        function deleteUnwantedFiles(~)
            fileList={'allThrdNames.txt','metadata_kernel','metadata_kernel_cleansed','metadata_ust','metadata_ust_cleansed'};
            try
                for index=1:numel(fileList)
                    if exist(fileList{index},'file')==2
                        delete(fileList{index});
                    end
                end
            catch
            end
        end
    end
end