


classdef FrequencyDrivenStrategy<fpconfig.ModeStrategy

    methods
        function obj=FrequencyDrivenStrategy(varargin)
        end

        function modeSettings=createModeSettings(~,varargin)
            modeSettings=fpconfig.FrequencyDrivenMode(varargin{:});
        end

        function obj=constructFromFields(~,varargin)
            obj=fpconfig.FrequencyDrivenIPSettings(varargin{:});
        end

        function obj=constructFromVisualStruct(~,lEntry)
            obj=fpconfig.FrequencyDrivenIPSettings.constructFromVisualStruct(lEntry);
        end

        function obj=constructFromVisualStructInString(~,lEntry)
            obj=fpconfig.FrequencyDrivenIPSettings.constructFromVisualStructInString(lEntry);
        end

        function obj=constructFromInternalStruct(~,lEntry)
            obj=fpconfig.FrequencyDrivenIPSettings.constructFromInternalStruct(lEntry);
        end

        function obj=constructDefault(~)
            obj=fpconfig.FrequencyDrivenIPSettings.constructDefault();
        end

        function[key,validNewKey,value]=fromVisualPV(~,varargin)
            [key,validNewKey,value]=fpconfig.FrequencyDrivenIPSettings.fromVisualPV(varargin{:});
        end

        function baseKey=getBaseKey(~,key)
            baseKey=fpconfig.FrequencyDrivenIPSettings.getBaseKey(key);
        end
    end
end

