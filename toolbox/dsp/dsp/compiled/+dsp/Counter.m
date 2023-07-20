classdef Counter<matlab.system.SFunSystem



























































































%#function mdspcount2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties



        Direction='Up';





        MaximumCount=255;



        InitialCount=0;






        HitValues=32;
    end

    properties(Nontunable)









        CountEventCondition='Non-zero';



        CounterSizeSource='Property'





        CounterSize='Maximum';





        SamplesPerFrame=1;





        CountOutputDataType='double';









        CountEventInputPort(1,1)logical=true;



        CountOutputPort(1,1)logical=true;




        HitOutputPort(1,1)logical=true;







        ResetInputPort(1,1)logical=true;
    end

    properties(Constant,Hidden)
        DirectionSet=matlab.system.StringSet({'Up','Down'});
        CountEventConditionSet=dsp.CommonSets.getSet('ResetCondition');
        CounterSizeSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        CounterSizeSet=matlab.system.StringSet({...
        '8 bits',...
        '16 bits',...
        '32 bits',...
        'Maximum'});
        CountOutputDataTypeSet=matlab.system.StringSet({...
        'double','single',...
        'int8','uint8',...
        'int16','uint16',...
        'int32','uint32'});
    end

    methods

        function obj=Counter(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:Counter_NotSupported');
            obj@matlab.system.SFunSystem('mdspcount2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods(Hidden)
        function setParameters(obj)
            CountDirectionIdx=getIndex(...
            obj.DirectionSet,obj.Direction);
            if obj.CountEventInputPort
                CountEventIdx=getIndex(...
                obj.CountEventConditionSet,obj.CountEventCondition);
            else
                CountEventIdx=5;
            end
            if strcmpi(obj.CounterSizeSource,'Input port')
                CounterSizeOptionIdx=5;
            else
                CounterSizeOptionIdx=getIndex(...
                obj.CounterSizeSet,obj.CounterSize);
            end
            coder.internal.errorIf(~obj.CountOutputPort&&~obj.HitOutputPort,...
            'dsp:system:Counter:noOutputsSpecified');
            OutputValueIdx=2*obj.HitOutputPort+obj.CountOutputPort;
            CountOutputDataTypeIdx=getIndex(...
            obj.CountOutputDataTypeSet,obj.CountOutputDataType);

            obj.compSetParameters({...
            CountDirectionIdx,...
            CountEventIdx,...
            CounterSizeOptionIdx,...
            obj.MaximumCount,...
            obj.InitialCount,...
            OutputValueIdx,...
            obj.HitValues,...
            double(obj.ResetInputPort),...
            obj.SamplesPerFrame,...
            1,...
            CountOutputDataTypeIdx,...
2...
            });
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'CountOutputDataType'
                if~obj.CountOutputPort
                    flag=true;
                end
            case 'HitValues'
                if~obj.HitOutputPort
                    flag=true;
                end
            case 'CounterSize'
                if strcmpi(obj.CounterSizeSource,'Input port')
                    flag=true;
                end
            case 'MaximumCount'
                if strcmpi(obj.CounterSizeSource,'Input port')
                    flag=true;
                end
            case 'SamplesPerFrame'
                if obj.CountEventInputPort
                    flag=true;
                end
            case 'CountEventCondition'
                if~obj.CountEventInputPort
                    flag=true;
                end
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspswit3/Counter';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'Direction'...
            ,'CountEventInputPort'...
            ,'CountEventCondition'...
            ,'CounterSizeSource'...
            ,'CounterSize'...
            ,'MaximumCount'...
            ,'InitialCount'...
            ,'CountOutputPort'...
            ,'HitOutputPort'...
            ,'HitValues'...
            ,'ResetInputPort'...
            ,'SamplesPerFrame'...
            ,'CountOutputDataType'...
            };
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.MaximumCount=3;
            tunePropsMap.InitialCount=4;
            tunePropsMap.HitValues=6;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end


