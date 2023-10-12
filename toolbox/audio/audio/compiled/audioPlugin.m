classdef audioPlugin<audio.internal.mixin.ParameterTunable


%#codegen

    methods
        function plugin=audioPlugin
            coder.allowpcode('plain');
            plugin.thisPtr=audioPlugin.wormholeToConstructor;
            if isempty(coder.target)
                plugin.pMIDIInterface=MIDIInterface(plugin);
            end
        end
    end



    properties(Access=private)
        PrivateSampleRate=44100
    end

    properties(Access=private)
pMIDIInterface
    end

    methods(Hidden)
        function midi=getMIDIInterface(plugin)
            midi=plugin.pMIDIInterface;
        end

        function delete(plugin)
            if~isempty(plugin.pMIDIInterface)&&isvalid(plugin.pMIDIInterface)
                delete(plugin.pMIDIInterface);
            end
        end
    end

    methods
        function rate=getSampleRate(plugin)
            rate=plugin.PrivateSampleRate;
        end
        function setSampleRate(plugin,rate)
            validateattributes(rate,{'numeric'},...
            {'real','scalar','finite','nonnegative'},...
            'setSampleRate','rate');
            plugin.PrivateSampleRate=double(rate);
        end

        function s=saveobj(obj)
            s.PrivateSampleRate=obj.PrivateSampleRate;
            s.PrivateLatency=obj.PrivateLatency;


        end
        function obj=reload(obj,s)
            obj.PrivateSampleRate=s.PrivateSampleRate;
            obj.PrivateLatency=s.PrivateLatency;
        end
    end

    properties(Access=private)
        thisPtr=uint64(0);
    end

    methods(Hidden)
        function setSampleRateForReset(plugin,rate)
            if nargin<2

                rate=coder.nullcopy(0);
                rate=coder.ceval('baseGetSampleRate',plugin.thisPtr);
            end
            plugin.PrivateSampleRate=rate;
        end
    end




    properties(Access=protected)
        PrivateLatency=int32(0)
    end

    methods(Access=protected)
        function setLatencyInSamples(plugin,numSamples)

            validateattributes(numSamples,{'numeric'},...
            {'real','scalar','finite','nonnegative','integer'},...
            'setLatencyInSamples','numSamples');
            plugin.PrivateLatency=int32(numSamples);
        end
    end

    methods(Static)
        function obj=loadobj(s)
            if isstruct(s)
                obj=audioPlugin;
                obj=reload(obj,s);
            end
        end
    end

    methods(Static,Hidden)
        function out=wormholeToConstructor(in)
            coder.inline('always');
            persistent thisPtr
            if isempty(thisPtr)
                if nargin>0
                    thisPtr=in;
                else
                    thisPtr=uint64(0);
                end
            end
            out=thisPtr;
        end
    end
end
