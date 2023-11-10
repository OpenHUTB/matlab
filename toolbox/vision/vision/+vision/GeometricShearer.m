classdef GeometricShearer<matlab.system.SFunSystem

%#function mvipshear

%#ok<*EMCLS>
%#ok<*EMCA>

    properties
        BackgroundFillValue=0;
    end

    properties(Nontunable)
        Direction='Horizontal';
        OutputSize='Full';
        ValuesSource='Property';
        Values=[0,3];
        MaximumValue=20;
        InterpolationMethod='Bilinear';
        RoundingMethod='Nearest';
        OverflowAction='Saturate';
        ValuesDataType='Same word length as input';
        CustomValuesDataType=numerictype([],32,10);
        ProductDataType='Custom';
        CustomProductDataType=numerictype([],32,10);

        AccumulatorDataType='Same as product';
        CustomAccumulatorDataType=numerictype([],32,10);

        OutputDataType='Same as first input';
        CustomOutputDataType=numerictype([],32,10);
    end

    properties(Constant,Hidden)
        DirectionSet=matlab.system.StringSet(...
        {'Horizontal','Vertical'});
        OutputSizeSet=matlab.system.StringSet(...
        {'Full','Same as input image'});
        ValuesSourceSet=...
        dsp.CommonSets.getSet('PropertyOrInputPort');
        InterpolationMethodSet=...
        matlab.system.StringSet({'Nearest neighbor','Bilinear','Bicubic'});


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ValuesDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeEitherScale');
        ProductDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeProdFirst');
        OutputDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
    end

    methods
        function obj=GeometricShearer(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipshear');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomValuesDataType(obj,val)
            validateCustomDataType(obj,'CustomValuesDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomValuesDataType=val;
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductDataType=val;
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
            DirectionIdx=getIndex(obj.DirectionSet,obj.Direction);
            OutputSizeIdx=getIndex(obj.OutputSizeSet,obj.OutputSize);
            ValuesSourceIdx=getIndex(obj.ValuesSourceSet,...
            obj.ValuesSource);
            InterpolationMethodIdx=getIndex(obj.InterpolationMethodSet,...
            obj.InterpolationMethod);

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                DirectionIdx,...
                OutputSizeIdx,...
                ValuesSourceIdx,...
                obj.Values,...
                obj.MaximumValue,...
                obj.BackgroundFillValue,...
                InterpolationMethodIdx,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                1});
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'Values','Product','Accumulator','Output'});

                obj.compSetParameters({...
                DirectionIdx,...
                OutputSizeIdx,...
                ValuesSourceIdx,...
                obj.Values,...
                obj.MaximumValue,...
                obj.BackgroundFillValue,...
                InterpolationMethodIdx,...
                dtInfo.ValuesDataType,...
                dtInfo.ValuesWordLength,...
                dtInfo.ValuesFracLength,...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction});
            end
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            if strcmp(obj.ValuesSource,'Property')
                props={'MaximumValue'};
                if~matlab.system.isSpecifiedTypeMode(obj.ValuesDataType)
                    props{end+1}='CustomValuesDataType';
                end
            else
                props={'Values',...
                'ValuesDataType','CustomValuesDataType'};
            end

            if strcmp(obj.InterpolationMethod,'Nearest neighbor')
                props=[props,{'ProductDataType','CustomProductDataType'}];
            else
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    props{end+1}='CustomProductDataType';
                end
            end
            if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                props{end+1}='CustomAccumulatorDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                props{end+1}='CustomOutputDataType';
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static,Hidden)

        function props=getDisplayPropertiesImpl()
            props={...
            'Direction',...
            'OutputSize',...
            'ValuesSource',...
            'Values',...
            'MaximumValue',...
            'BackgroundFillValue',...
'InterpolationMethod'
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'ValuesDataType','CustomValuesDataType'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            ,'OutputDataType','CustomOutputDataType'...
            };
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.BackgroundFillValue=5;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.GeometricShearer',...
            vision.GeometricShearer.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visiongeotforms/Shear';
        end
    end
end
