classdef(Abstract)PayloadBuilder<handle




    properties(Access=protected)
ProfileInterface
Config
    end

    properties(SetAccess=protected)
IsConfigured
    end

    methods
        function obj=PayloadBuilder(profileInterface)
            obj.ProfileInterface=profileInterface;
            obj.IsConfigured=false;
            mlock;
        end

        function configure(obj,config)
            obj.Config=obj.customizeConfig(config);
            obj.IsConfigured=true;
        end
    end

    methods(Abstract)
        viewPayload=build(obj)
    end

    methods(Access=protected)
        function config=customizeConfig(~,config)

        end

        function ensureIsConfigured(obj)
            assert(obj.IsConfigured,'Builder is not configured.')
        end
    end

    methods(Static)
        function config=makeDefaultBuilderConfig()
            config.WithMemoryData=false;
        end
    end
end
