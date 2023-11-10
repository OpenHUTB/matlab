classdef AlphaBlender<matlab.system.SFunSystem

%#function mvipcomposite

%#ok<*EMCLS>
%#ok<*EMCA>

    properties

        Opacity=0.75;

        Mask=1;

        Location;
    end

    properties(Nontunable)
        Operation='Blend';
        OpacitySource='Property';
        MaskSource='Property';
        LocationSource='Property';
        RoundingMethod='Floor';
        OverflowAction='Wrap';
        OpacityDataType='Same word length as input';
        CustomOpacityDataType=numerictype([],16);

        ProductDataType='Custom';

        CustomProductDataType=numerictype([],32,10);

        AccumulatorDataType='Same as product';
        CustomAccumulatorDataType=numerictype([],32,10);

        OutputDataType='Same as first input';
        CustomOutputDataType=numerictype([],32,10);
    end

    properties(Constant,Hidden)
        OperationSet=matlab.system.StringSet({...
        'Blend',...
        'Binary mask',...
        'Highlight selected pixels'});
        OpacitySourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        MaskSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        LocationSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        OpacityDataTypeSet=dsp.CommonSets.getSet('FixptModeUnscaled');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProdFirst');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
    end

    methods
        function obj=AlphaBlender(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipcomposite');
            setProperties(obj,nargin,varargin{:});
            if isempty(obj.Location)
                obj.Location=[1,1];
            end
        end

        function set.CustomOpacityDataType(obj,val)
            validateCustomDataType(obj,'CustomOpacityDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomOpacityDataType=val;
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
            OperationIdx=getIndex(obj.OperationSet,obj.Operation);
            OpacitySourceIdx=getIndex(obj.OpacitySourceSet,obj.OpacitySource);
            MaskSourceIdx=getIndex(obj.MaskSourceSet,obj.MaskSource);
            LocationSourceIdx=getIndex(obj.LocationSourceSet,obj.LocationSource);

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                OperationIdx,...
                OpacitySourceIdx,...
                MaskSourceIdx,...
                obj.Opacity,...
                obj.Mask,...
                LocationSourceIdx,...
                obj.Location,...
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
2
                });
            else

                dtInfo=getFixptDataTypeInfo(obj,{...
                'Opacity','Product','Accumulator','Output'});
                obj.compSetParameters({...
                OperationIdx,...
                OpacitySourceIdx,...
                MaskSourceIdx,...
                obj.Opacity,...
                obj.Mask,...
                LocationSourceIdx,...
                obj.Location,...
                dtInfo.OpacityDataType,...
                dtInfo.OpacityWordLength,...
                dtInfo.OpacityFracLength,...
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
                dtInfo.OverflowAction...
                });
            end
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            switch(obj.Operation)
            case 'Blend'
                props={'MaskSource','Mask'};
                if~strcmp(obj.OpacitySource,'Property')
                    props=[props,{'Opacity',...
                    'OpacityDataType','CustomOpacityDataType'}];
                else
                    if~matlab.system.isSpecifiedTypeMode(obj.OpacityDataType)
                        props{end+1}='CustomOpacityDataType';
                    end
                end
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    props{end+1}='CustomProductDataType';
                end
                if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    props{end+1}='CustomAccumulatorDataType';
                end
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    props{end+1}='CustomOutputDataType';
                end

            case 'Binary mask'
                props={'OpacitySource','Opacity',...
                'RoundingMethod','OverflowAction',...
                'OpacityDataType','CustomOpacityDataType',...
                'ProductDataType','CustomProductDataType',...
                'AccumulatorDataType','CustomAccumulatorDataType',...
                'OutputDataType','CustomOutputDataType'};
                if~strcmp(obj.MaskSource,'Property')
                    props{end+1}='Mask';
                end

            case 'Highlight selected pixels'
                props={'OpacitySource','Opacity',...
                'MaskSource','Mask',...
                'RoundingMethod','OverflowAction',...
                'OpacityDataType','CustomOpacityDataType',...
                'ProductDataType','CustomProductDataType',...
                'AccumulatorDataType','CustomAccumulatorDataType',...
                'OutputDataType','CustomOutputDataType'};
            end
            if~strcmp(obj.LocationSource,'Property')
                props{end+1}='Location';
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.AlphaBlender',...
            vision.AlphaBlender.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
            'Operation',...
            'OpacitySource',...
            'Opacity',...
            'MaskSource',...
            'Mask',...
            'LocationSource',...
            'Location'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction',...
            'OpacityDataType','CustomOpacityDataType',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType'};
        end


        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Opacity=3;
            tunePropsMap.Mask=4;
            tunePropsMap.Location=6;
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
            a='visiontextngfix/Compositing';
        end
    end
end
