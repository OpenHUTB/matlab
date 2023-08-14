classdef DMA<soc.BaseIpCore




    properties

    end
    methods
        function obj=DMA(axiMaster,ipCoreInfo,varargin)
            obj.AXIMaster=axiMaster;
            obj.IPCoreInfo=ipCoreInfo;
            obj.IPCoreName='DMA';
        end
    end
end