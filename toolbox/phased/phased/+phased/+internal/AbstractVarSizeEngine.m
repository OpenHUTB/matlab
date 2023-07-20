classdef(Hidden)AbstractVarSizeEngine<matlab.System






%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

    properties(Access=protected)
        pNumInputChannels=-1
    end

    properties(Access=protected,Nontunable)
pValidatedNumInputChannels
    end

    methods(Access=protected)
        function flag=isInputDataSizePropagated(obj)
            coder.allowpcode('plain');
            flag=obj.getExecPlatformIndex();
        end

        function numchans=getNumChannels(obj,u)

            if obj.getExecPlatformIndex()
                thisSize=propagatedInputSize(obj,1);
                numchans=thisSize(2);
            else
                numchans=size(u,2);
            end
        end

        function numSamples=getPropagatedNumInputSamples(obj,u)


            if obj.getExecPlatformIndex()
                thisSize=propagatedInputSize(obj,1);
                if isempty(thisSize)
                    numSamples=1;
                else
                    numSamples=thisSize(1);
                end
            else
                numSamples=size(u,1);
            end
        end

        function validateNumChannels(obj,u)
            cond=isChannelInitiated(obj)&&...
            (size(u,2)~=obj.pNumInputChannels);
            if cond
                coder.internal.errorIf(cond,'phased:step:NumInputChannelNotConstant');
            end
        end

        function validateNumPages(obj,u,numpage)
            cond=isChannelInitiated(obj)&&...
            (size(u,3)~=numpage);
            if cond
                coder.internal.errorIf(cond,'phased:step:NumInputPageNotConstant');
            end
        end

        function flag=isChannelInitiated(obj)
            flag=(obj.pNumInputChannels~=-1);
        end

        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            if isLocked(obj)
                s.pNumInputChannels=obj.pNumInputChannels;
                s.pValidatedNumInputChannels=obj.pValidatedNumInputChannels;
            end
        end

        function releaseImpl(obj)
            obj.pNumInputChannels=-1;
        end

        function flag=useRandomizedSeed(obj)
            flag=obj.getExecPlatformIndex();
        end
    end

    methods(Static,Hidden)
        function validateSize(varargin)

        end
    end
end
