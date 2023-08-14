classdef CPULoadGenerator<matlab.System&coder.ExternalDependency






%#codegen


    properties

        ProxyTaskType=0;
        SampleRate=1;
    end

    properties(DiscreteState)
    end


    properties(Access=private)
        tnow;
        blkIdx;
    end

    methods

        function obj=CPULoadGenerator(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)

        function setupImpl(obj)
            coder.extrinsic('gcbh');
        end

        function sts=getSampleTimeImpl(obj)
            if(obj.SampleRate<0)
                if isequal(obj.ProxyTaskType,1)
                    error(message('soc:scheduler:ProxyTaskInAsyncRate'));
                end
                sts=obj.createSampleTime("Type","Inherited");
            else
                sts=obj.createSampleTime("Type","Discrete",...
                "SampleTime",obj.SampleRate);
            end
        end

        function y=stepImpl(obj,u)
            y=u;
        end

        function resetImpl(obj)

        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
        end

        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end



        function flag=isInputSizeMutableImpl(obj,index)


            flag=false;
        end

        function out=getOutputSizeImpl(obj)

            out=propagatedInputSize(obj,1);
        end

        function icon=getIconImpl(obj)

            icon=mfilename("class");
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            header=matlab.system.display.Header(mfilename("class"));
        end

        function group=getPropertyGroupsImpl

            group=matlab.system.display.Section(mfilename("class"));
        end
    end

    methods(Static)s
        function name=getDescriptiveName()
            name='SOC Busy Wait';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw');
        end

        function updateBuildInfo(buildInfo,context)
        end
    end

end
