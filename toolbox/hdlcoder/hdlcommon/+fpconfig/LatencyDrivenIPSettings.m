


classdef LatencyDrivenIPSettings<fpconfig.FrequencyDrivenIPSettings

    properties
        MinLatency;
        MaxLatency;
    end

    methods(Static)
        function fds=ReadWriteFields
            fds=ReadWriteFields@fpconfig.FrequencyDrivenIPSettings;
        end

        function fds=ReadOnlyFields
            fds={'MinLatency','MaxLatency'};
        end

        function fds=ValueFields
            supperFds=ValueFields@fpconfig.FrequencyDrivenIPSettings();
            fds={'MinLatency','MaxLatency',supperFds{:}};
        end

        function fds=KeyFields
            fds=KeyFields@fpconfig.FrequencyDrivenIPSettings;
        end

        function type=getFieldType(field)
            switch(field)
            case{'MinLatency','MaxLatency'}
                type='double';
            otherwise
                type=getFieldType@fpconfig.FrequencyDrivenIPSettings(field);
            end
        end
    end

    methods
        function obj=LatencyDrivenIPSettings(varargin)
            obj@fpconfig.FrequencyDrivenIPSettings(varargin{:});
        end

        function obj=set.MinLatency(obj,val)
            if(~isempty(obj.MinLatency)&&val~=obj.MinLatency)
                error(message('hdlcommon:targetcodegen:ReadOnlySetting'));
            end
            obj.MinLatency=int32(val);
        end

        function obj=set.MaxLatency(obj,val)
            if(~isempty(obj.MaxLatency)&&val~=obj.MaxLatency)
                error(message('hdlcommon:targetcodegen:ReadOnlySetting'));
            end
            obj.MaxLatency=int32(val);
        end

        function fromInternalStruct(obj,lEntry)
            fromInternalStruct@fpconfig.FrequencyDrivenIPSettings(obj,lEntry);
            obj.MinLatency=lEntry.minLatency;
            obj.MaxLatency=lEntry.maxLatency;
        end
    end

    methods(Static)
        function obj=constructFromVisualStruct(lEntry)
            obj=fpconfig.LatencyDrivenIPSettings();
            obj.fromVisualStruct(lEntry);
        end

        function obj=constructFromVisualStructInString(lEntry)
            obj=fpconfig.LatencyDrivenIPSettings();
            obj.fromVisualStructInString(lEntry);
        end

        function obj=constructFromInternalStruct(lEntry)
            obj=fpconfig.LatencyDrivenIPSettings();
            obj.fromInternalStruct(lEntry);
        end
    end

    methods(Access=public,Hidden=true)
        function obj=construct(~)
            obj=fpconfig.FrequencyDrivenIPSettings();
        end
    end
end

