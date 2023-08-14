classdef TrafficGen<soc.BaseIpCore




    properties

    end
    methods
        function obj=TrafficGen(axiMaster,ipCoreInfo,varargin)
            obj.AXIMaster=axiMaster;
            obj.IPCoreInfo=ipCoreInfo;
            obj.IPCoreName='TrafficGenerator';
        end
        function start(obj)
            soc.util.enableATGs(obj.AXIMaster,obj.IPCoreInfo);
        end
    end
end

