classdef DelayLine<matlab.system.SFunSystem












































































%#function mdspsreg2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        Length=64;











        InitialConditions=0;







        DirectFeedthrough(1,1)logical=false;












        EnableOutputInputPort(1,1)logical=false;






        HoldPreviousValue(1,1)logical=false;
    end

    methods

        function obj=DelayLine(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:DelayLine_NotSupported');
            obj@matlab.system.SFunSystem('mdspsreg2');
            setProperties(obj,nargin,varargin{:},'Length','InitialConditions');
            setVarSizeAllowedStatus(obj,false);
        end

    end

    methods(Hidden)
        function setParameters(obj)


            obj.compSetParameters({...
            obj.Length,...
            obj.InitialConditions,...
            double(obj.DirectFeedthrough),...
            double(obj.EnableOutputInputPort),...
            double(obj.HoldPreviousValue),...
1
            });
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if strcmp(prop,'HoldPreviousValue')&&(~obj.EnableOutputInputPort)
                flag=true;
            end
        end

    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspbuff3/Delay Line';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'Length'...
            ,'InitialConditions'...
            ,'DirectFeedthrough'...
            ,'EnableOutputInputPort'...
            ,'HoldPreviousValue'...
            };
        end


        function props=getValueOnlyProperties()
            props={'Length','InitialConditions'};
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end

