classdef PerfMon<soc.BaseIpCore




    properties
ProfileDataStruct
    end
    methods
        function obj=PerfMon(jtagObj,ipCoreInfo,varargin)
            obj.AXIMaster=jtagObj;
            obj.IPCoreInfo=ipCoreInfo;
            p=inputParser;
            addParameter(p,'Mode','Profile');
            parse(p,varargin{:});
            obj.IPCoreInfo.Mode=p.Results.Mode;
            obj.IPCoreName='PerformanceMonitor';
        end
    end
end

