classdef VDMAFrameBuffer<soc.BaseIpCore




    properties

    end
    methods
        function obj=VDMAFrameBuffer(axiMaster,ipCoreInfo,varargin)
            obj.AXIMaster=axiMaster;
            obj.IPCoreInfo=ipCoreInfo;
            obj.IPCoreName='FrameBuffer';
        end
    end
end