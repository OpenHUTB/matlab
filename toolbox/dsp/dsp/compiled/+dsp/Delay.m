classdef Delay<matlab.system.SFunSystem
























































%#function mdspdelay

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)








        Length=1;






















        InitialConditions=0;






        ResetCondition='Non-zero';





        InitialConditionsPerChannel(1,1)logical=false;




        InitialConditionsPerSample(1,1)logical=false;








        ResetInputPort(1,1)logical=false;
    end

    properties(Nontunable,Hidden)

        Units='Samples';
    end

    properties(Constant,Hidden)
        UnitsSet=matlab.system.StringSet({'Samples'});
        ResetConditionSet=dsp.CommonSets.getSet('ResetCondition');
    end

    methods
        function obj=Delay(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspdelay');
            setProperties(obj,nargin,varargin{:},'Length');
            setEmptyAllowedStatus(obj,true);
            setFrameStatus(obj,true);
        end

    end

    methods(Hidden)
        function setParameters(obj)
            UnitsIdx=getIndex(obj.UnitsSet,obj.Units);
            if obj.ResetInputPort
                ResetDelayIdx=getIndex(obj.ResetConditionSet,...
                obj.ResetCondition);
            else
                ResetDelayIdx=0;
            end
            [~,pInitialConditions]=dspblkdelay('init',...
            obj.Units,double(obj.Length),...
            obj.InitialConditions);


            InputProcessing=1;

            obj.compSetParameters({...
            UnitsIdx,...
            obj.Length,...
            double(obj.InitialConditionsPerChannel),...
            double(obj.InitialConditionsPerSample),...
            pInitialConditions,...
            ResetDelayIdx,...
InputProcessing...
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsigops/Delay';
        end



        function props=getDisplayPropertiesImpl()
            props={...
'Length'...
            ,'InitialConditionsPerChannel'...
            ,'InitialConditionsPerSample'...
            ,'InitialConditions'...
            ,'ResetInputPort',...
            'ResetCondition',...
            };
        end


        function props=getValueOnlyProperties()
            props={'Length'};
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if strcmp(prop,'ResetCondition')&&~obj.ResetInputPort
                flag=true;
            end
        end

        function loadObjectImpl(obj,s,~)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end


