classdef MemoryProfiler<handle
    properties(Access=private)
ProfileDataStruct
TraceDataStruct
TracelogInst
HwObj
ApmCoreObj
    end
    methods
        function profilerObj=MemoryProfiler(hwObj,apmCoreObj)
            if isa(hwObj,'ioplayback.hardware.Base')
                profilerObj.HwObj=hwObj;
            else
                error(message('soc:utils:InvalidHardwareObject'));
            end
            profilerObj.ProfileDataStruct=apmCoreObj.ProfileDataStruct;
            profilerObj.ApmCoreObj=apmCoreObj;
        end
        function collectMemoryStatistics(profilerObj)
            if strcmp(profilerObj.ApmCoreObj.IPCoreInfo.Mode,'Profile')
                profilerObj.ProfileDataStruct=soc.util.runProfile(profilerObj.ApmCoreObj.AXIMaster,...
                profilerObj.ApmCoreObj.IPCoreInfo,profilerObj.ProfileDataStruct);
            else
                profilerObj.TraceDataStruct=soc.util.stopTrace(profilerObj.ApmCoreObj.AXIMaster,...
                profilerObj.ApmCoreObj.IPCoreInfo);
            end
        end

        function plotMemoryStatistics(profilerObj)
            switch profilerObj.ApmCoreObj.IPCoreInfo.Mode
            case 'Profile'
                soc.util.plotProfile(profilerObj.ApmCoreObj.IPCoreInfo,profilerObj.ProfileDataStruct);
            otherwise
                if~isempty(profilerObj.TraceDataStruct)
                    profilerObj.TracelogInst=soc.util.plotTrace(profilerObj.ApmCoreObj.IPCoreInfo,...
                    profilerObj.TraceDataStruct);
                end
            end
        end
    end
end

