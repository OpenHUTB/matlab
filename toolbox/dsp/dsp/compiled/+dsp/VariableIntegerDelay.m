classdef VariableIntegerDelay<matlab.system.SFunSystem



























































%#function mdspvdly2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)















        InitialConditions=0;





        MaximumDelay=100;
    end

    methods

        function obj=VariableIntegerDelay(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspvdly2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,true);
            setEmptyAllowedStatus(obj,true);

            setFrameStatus(obj,true);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            InputProcessing=1;
            DFT=true;


            obj.compSetParameters({...
            0,...
            obj.MaximumDelay,...
            InputProcessing,...
            0,...
            obj.InitialConditions...
            ,0,0,0,0,0,0...
            ,double(~DFT),...
            2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
            });
        end

        function y=supportsUnboundedIO(~)
            y=true;
        end

    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsigops/Variable Integer Delay';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'InitialConditions'...
            ,'MaximumDelay'...
            };
        end

        function b=generatesCode
            b=true;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function loadObjectImpl(obj,s,~)
            if(isfield(s,'DirectFeedthrough'))
                s=rmfield(s,'DirectFeedthrough');
            end
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end
    end
end
