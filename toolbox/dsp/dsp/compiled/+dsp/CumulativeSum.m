classdef CumulativeSum<matlab.system.SFunSystem





















































%#function mdspcumsumprod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        Dimension='Channels (running sum)';








        ResetCondition='Rising edge';







        RoundingMethod='Floor';




        OverflowAction='Wrap';




        AccumulatorDataType='Same as input';








        CustomAccumulatorDataType=numerictype([],32,30);





        OutputDataType='Same as accumulator';








        CustomOutputDataType=numerictype([],16,15);









        ResetInputPort(1,1)logical=false;
    end

    properties(Hidden,Constant)
        DimensionSet=matlab.system.StringSet({...
        'Columns',...
        'Rows',...
        'Channels (running sum)'});
        ResetConditionSet=dsp.CommonSets.getSet('ResetCondition');
        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');
    end

    methods

        function obj=CumulativeSum(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:CumulativeSum_NotSupported');
            obj@matlab.system.SFunSystem('mdspcumsumprod');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
            setFrameStatus(obj,true);
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomOutputDataType=val;
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.CumulativeSum',dsp.CumulativeSum.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Access=protected)



        function flag=isInactivePropertyImpl(obj,prop)


            flag=false;
            switch prop
            case{'ResetInputPort'}
                if~strcmp(obj.Dimension,'Channels (running sum)')
                    flag=true;
                end
            case 'ResetCondition'
                if~strcmp(obj.Dimension,'Channels (running sum)')||...
                    ~obj.ResetInputPort
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    flag=true;
                end
            case 'CustomOutputDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            end
        end

        function loadObjectImpl(obj,s,~)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end

    end

    methods(Hidden)
        function setParameters(obj)
            dimIndex=getIndex(obj.DimensionSet,obj.Dimension);

            ResetConditionIdx=getIndex(...
            obj.ResetConditionSet,obj.ResetCondition);

            if(obj.ResetInputPort)
                resetModeIndex=ResetConditionIdx;
            else
                resetModeIndex=0;
            end


            InputProcessing=1;

            if isSizesOnlyCall(obj)
                obj.compSetParameters({dimIndex,...
                InputProcessing,...
                resetModeIndex,...
                0,...
                [],[],...
                -1,0,0,...
                -1,0,0,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,{'Accumulator','Output'});
                obj.compSetParameters({dimIndex,...
                InputProcessing,...
                resetModeIndex,...
                0,...
                [],[],...
                -1,0,0,...
                -1,0,0,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspmathops/Cumulative Sum';
        end

        function props=getDisplayPropertiesImpl()
            props={'Dimension','ResetInputPort',...
            'ResetCondition'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'RoundingMethod','OverflowAction',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType'};
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
