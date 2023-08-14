classdef BaseIpCore<handle



    properties(SetAccess=protected)
IPCoreInfo
AXIMaster
IPCoreName
    end

    methods
        function initialize(obj,varargin)
            switch obj.IPCoreName
            case 'TrafficGenerator'
                soc.util.initATG(obj.AXIMaster,obj.IPCoreInfo);
            case 'PerformanceMonitor'
                if strcmp(obj.IPCoreInfo.Mode,'Profile')
                    obj.ProfileDataStruct=soc.util.initProfile(obj.AXIMaster,obj.IPCoreInfo);
                elseif strcmp(obj.IPCoreInfo.Mode,'Trace')
                    soc.util.startTrace(obj.AXIMaster,obj.IPCoreInfo);
                end
            case 'VDMA'
                p=inputParser;
                addParameter(p,'frameParam',[]);
                addParameter(p,'memoryRegion',[]);
                parse(p,varargin{:});
                frameParam=p.Results.frameParam;
                memoryRegion=p.Results.memoryRegion;
                soc.util.initVDMA(obj.AXIMaster,obj.IPCoreInfo,frameParam,memoryRegion);
            case 'DMA'
                p=inputParser;
                addParameter(p,'memoryRegion',[]);
                parse(p,varargin{:});
                memoryRegion=p.Results.memoryRegion;
                soc.util.initDMA(obj.AXIMaster,obj.IPCoreInfo,memoryRegion);
            case 'VTC'
                obj.FrameInfo=soc.util.initVTC(obj.AXIMaster,obj.IPCoreInfo);
            case{'FrameBuffer','HDMI'}
                p=inputParser;
                addParameter(p,'frameParam',[]);
                addParameter(p,'memoryRegions',[]);
                parse(p,varargin{:});
                frameParam=p.Results.frameParam;
                memoryRegions=p.Results.memoryRegions;
                soc.util.initVDMAFrameBuffer(obj.AXIMaster,obj.IPCoreInfo,frameParam,memoryRegions);
            otherwise
                error(message('soc:msgs:unrecognizeIPType',ipcoreName));
            end
        end
    end
end