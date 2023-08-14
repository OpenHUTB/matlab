classdef(Sealed=true)TargetInfo<realtime.Info






    properties(SetAccess='private')
        ProdHWDeviceType='Generic->Custom';
        ExtModeTrigDuration=2;
        ExtModeTransport=0;
        ExtModeConnectPause=0;
        ExtModeMexArgsInit='';
        ExtModeDisablePrintf=true;
        ExtModeDisableArgsProcessing=true;
        RTTParams=[];
    end

    properties(Constant)
    end


    methods
        function h=TargetInfo(filePathName,hardwareName,varargin)
            h.deserialize(filePathName,hardwareName,varargin);
        end

        function set(h,property,value)
            h.(property)=value;
        end
    end


    methods(Access='private')
    end
end
