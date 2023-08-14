classdef VTC<soc.BaseIpCore




    properties
FrameInfo
    end
    methods
        function obj=VTC(axiMaster,ipCoreInfo,varargin)
            obj.AXIMaster=axiMaster;
            obj.IPCoreInfo=ipCoreInfo;
            obj.IPCoreName='VTC';
        end
    end
end