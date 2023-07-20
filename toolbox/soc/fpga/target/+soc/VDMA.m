classdef VDMA<soc.BaseIpCore




    properties

    end
    methods
        function obj=VDMA(axiMaster,ipCoreInfo,varargin)
            obj.AXIMaster=axiMaster;
            obj.IPCoreInfo=ipCoreInfo;
            obj.IPCoreName='VDMA';
        end
    end
end