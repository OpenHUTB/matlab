


classdef NFPLatencyDrivenStrategy<fpconfig.LatencyDrivenStrategy

    methods
        function obj=NFPLatencyDrivenStrategy(varargin)
        end

        function modeSettings=createModeSettings(~,varargin)
            modeSettings=fpconfig.NFPLatencyDrivenMode(varargin{:});
        end

        function obj=constructFromFields(~,varargin)
            obj=fpconfig.NFPLatencyDrivenIPSettings(varargin{:});
        end

        function obj=constructFromVisualStruct(~,lEntry)
            obj=fpconfig.NFPLatencyDrivenIPSettings.constructFromVisualStruct(lEntry);
        end

        function obj=constructFromVisualStructInString(~,lEntry)
            obj=fpconfig.NFPLatencyDrivenIPSettings.constructFromVisualStructInString(lEntry);
        end

        function obj=constructFromInternalStruct(~,lEntry)
            obj=fpconfig.NFPLatencyDrivenIPSettings.constructFromInternalStruct(lEntry);
        end

        function obj=constructDefault(~)
            obj=fpconfig.NFPLatencyDrivenIPSettings.constructDefault();
        end

        function[key,validNewKey,value]=fromVisualPV(~,varargin)
            [key,validNewKey,value]=fpconfig.NFPLatencyDrivenIPSettings.fromVisualPV(varargin{:});
        end

        function baseKey=getBaseKey(~,key)
            baseKey=fpconfig.NFPLatencyDrivenIPSettings.getBaseKey(key);
        end
    end
end

