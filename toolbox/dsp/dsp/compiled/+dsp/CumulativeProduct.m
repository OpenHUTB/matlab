classdef CumulativeProduct<matlab.system.SFunSystem






















































%#function mdspcumsumprod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        Dimension='Channels (running product)';








        ResetCondition='Rising edge';






        RoundingMethod='Floor';




        OverflowAction='Wrap';





        IntermediateProductDataType='Same as input';










        CustomIntermediateProductDataType=numerictype([],16,15);




        ProductDataType='Same as input';








        CustomProductDataType=numerictype([],32,30);





        AccumulatorDataType='Same as input';








        CustomAccumulatorDataType=numerictype([],32,30);





        OutputDataType='Same as input';








        CustomOutputDataType=numerictype([],16,15);









        ResetInputPort(1,1)logical=false;
    end

    properties(Hidden,Constant)
        DimensionSet=matlab.system.StringSet({...
        'Columns',...
        'Rows',...
        'Channels (running product)'});
        ResetConditionSet=dsp.CommonSets.getSet('ResetCondition');
        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        IntermediateProductDataTypeSet=...
        dsp.CommonSets.getSet('FixptModeBasic');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeProd');
    end

    methods

        function obj=CumulativeProduct(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:CumulativeProduct_NotSupported');
            obj@matlab.system.SFunSystem('mdspcumsumprod');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
            setFrameStatus(obj,true);
        end

        function set.CustomIntermediateProductDataType(obj,val)
            validateCustomDataType(obj,'CustomIntermediateProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomIntermediateProductDataType=val;
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

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.CumulativeProduct',dsp.CumulativeProduct.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Access=protected)


        function flag=isInactivePropertyImpl(obj,prop)


            flag=false;
            switch prop
            case{'ResetInputPort'}
                if~strcmp(obj.Dimension,'Channels (running product)')
                    flag=true;
                end
            case 'ResetCondition'
                if~strcmp(obj.Dimension,'Channels (running product)')||...
                    ~obj.ResetInputPort
                    flag=true;
                end
            case 'CustomIntermediateProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.IntermediateProductDataType)
                    flag=true;
                end
            case 'CustomProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
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
                1,...
                [],[],...
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
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'IntermediateProduct','Product','Accumulator','Output'});
                obj.compSetParameters({dimIndex,...
                InputProcessing,...
                resetModeIndex,...
                1,...
                [],[],...
                dtInfo.IntermediateProductDataType,...
                dtInfo.IntermediateProductWordLength,...
                dtInfo.IntermediateProductFracLength,...
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

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspmathops/Cumulative Product';
        end

        function props=getDisplayPropertiesImpl()
            props={'Dimension','ResetInputPort',...
            'ResetCondition'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'RoundingMethod','OverflowAction',...
            'IntermediateProductDataType','CustomIntermediateProductDataType',...
            'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType',...
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
