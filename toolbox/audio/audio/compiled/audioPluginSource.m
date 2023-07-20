classdef audioPluginSource<audioPlugin






















%#codegen

    methods
        function plugin=audioPluginSource
            coder.allowpcode('plain');
        end
    end





    properties(Access=private)
        PrivateSamplesPerFrame=256
    end
    methods
        function n=getSamplesPerFrame(plugin)
            n=plugin.PrivateSamplesPerFrame;
        end
        function setSamplesPerFrame(plugin,numSamples)
            validateattributes(numSamples,{'numeric'},...
            {'real','scalar','finite','nonnegative','integer'},...
            'setSamplesPerFrame','numSamples');
            plugin.PrivateSamplesPerFrame=double(numSamples);
        end
        function s=saveobj(obj)
            s=saveobj@audioPlugin(obj);
            s.PrivateSamplesPerFrame=obj.PrivateSamplesPerFrame;
        end
        function obj=reload(obj,s)
            obj=reload@audioPlugin(obj,s);
            obj.PrivateSamplesPerFrame=s.PrivateSamplesPerFrame;
        end
    end

    methods(Static)
        function obj=loadobj(s)
            if istruct(s)
                obj=audioPluginSource;
                obj=reload(obj,s);
            end
        end
    end

    methods(Hidden)
        function setSamplesPerFrameForProcess(plugin,n)
            plugin.PrivateSamplesPerFrame=double(n);
        end
    end

end
