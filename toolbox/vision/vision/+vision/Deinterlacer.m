classdef Deinterlacer<matlab.system.SFunSystem














































%#function mvipdeinterlace

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        Method='Line repetition';






        RoundingMethod='Floor';


        OverflowAction='Wrap';



        AccumulatorDataType='Custom';







        CustomAccumulatorDataType=numerictype([],12,3);



        OutputDataType='Same as input';







        CustomOutputDataType=numerictype([],8,0);






        TransposedInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        MethodSet=matlab.system.StringSet(...
        {'Line repetition',...
        'Linear interpolation',...
        'Vertical temporal median filtering'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
    end

    methods
        function obj=Deinterlacer(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipdeinterlace');
            setProperties(obj,nargin,varargin{:});
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

    methods(Hidden)
        function setParameters(obj)
            MethodIdx=obj.MethodSet.getIndex(obj.Method);

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                MethodIdx,...
                double(obj.TransposedInput),...
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

                obj.compSetParameters({...
                MethodIdx,...
                double(obj.TransposedInput),...
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

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            if~strcmp(obj.Method,'Linear interpolation')
                props={'RoundingMethod','OverflowAction',...
                'AccumulatorDataType','CustomAccumulatorDataType',...
                'OutputDataType','CustomOutputDataType'};
            else
                props={};
                if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    props{end+1}='CustomAccumulatorDataType';
                end
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    props{end+1}='CustomOutputDataType';
                end
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.Deinterlacer',...
            vision.Deinterlacer.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={'Method','TransposedInput'};
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

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionanalysis/Deinterlacing';
        end
    end
end
