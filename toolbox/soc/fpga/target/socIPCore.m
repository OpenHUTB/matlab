function ipCoreObj=socIPCore(jtagObj,IPCoreInfo,IPCoreName,varargin)






















































    if strcmp(IPCoreName,'TrafficGenerator')
        ipCoreObj=soc.TrafficGen(jtagObj,IPCoreInfo,varargin{:});
    elseif strcmp(IPCoreName,'PerformanceMonitor')
        ipCoreObj=soc.PerfMon(jtagObj,IPCoreInfo,varargin{:});
    elseif strcmp(IPCoreName,'VDMA')
        ipCoreObj=soc.VDMA(jtagObj,IPCoreInfo,varargin{:});
    elseif strcmp(IPCoreName,'DMA')
        ipCoreObj=soc.DMA(jtagObj,IPCoreInfo,varargin{:});
    elseif strcmp(IPCoreName,'VTC')
        ipCoreObj=soc.VTC(jtagObj,IPCoreInfo,varargin{:});
    elseif strcmp(IPCoreName,'FrameBuffer')
        ipCoreObj=soc.VDMAFrameBuffer(jtagObj,IPCoreInfo,varargin{:});
    elseif strcmp(IPCoreName,'HDMI')
        ipCoreObj=soc.VDMAFrameBuffer(jtagObj,IPCoreInfo,varargin{:});
    else
        error(message('soc:msgs:unrecognizeIPType',IPCoreName));
    end
end
