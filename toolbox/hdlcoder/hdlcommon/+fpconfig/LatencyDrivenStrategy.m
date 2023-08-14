


classdef LatencyDrivenStrategy<fpconfig.FrequencyDrivenStrategy

    methods
        function obj=LatencyDrivenStrategy(varargin)
        end

        function modeSettings=createModeSettings(~,varargin)
            modeSettings=fpconfig.LatencyDrivenMode(varargin{:});
        end

        function obj=constructFromFields(~,varargin)
            obj=fpconfig.LatencyDrivenIPSettings(varargin{:});
        end

        function obj=constructFromVisualStruct(~,lEntry)
            obj=fpconfig.LatencyDrivenIPSettings.constructFromVisualStruct(lEntry);
        end

        function obj=constructFromVisualStructInString(~,lEntry)
            obj=fpconfig.LatencyDrivenIPSettings.constructFromVisualStructInString(lEntry);
        end

        function obj=constructFromInternalStruct(~,lEntry)
            obj=fpconfig.LatencyDrivenIPSettings.constructFromInternalStruct(lEntry);
        end
    end
end

