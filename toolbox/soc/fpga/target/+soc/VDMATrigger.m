classdef VDMATrigger<soc.BaseIpCore






    methods
        function obj=VDMATrigger(jtagObj,ipCoreInfo,varargin)
            obj.AXIMaster=jtagObj;
            obj.IPCoreInfo=ipCoreInfo;
            obj.IPCoreName='VDMATrigger';
        end

        function start(obj)
            writememory(obj.AXIMaster,obj.IPCoreInfo.TRIGGER_IN,uint32(1));
            writememory(obj.AXIMaster,obj.IPCoreInfo.TRIGGER_IN,uint32(0));
        end
    end
end