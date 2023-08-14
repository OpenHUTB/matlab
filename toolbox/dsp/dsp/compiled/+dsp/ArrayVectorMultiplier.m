classdef ArrayVectorMultiplier<matlab.system.SFunSystem


























































%#function mdspdmult2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties




        Vector=[0.5,0.25];
    end

    properties(Nontunable)




        Dimension=2;



        VectorSource='Input port';







        RoundingMethod='Floor';



        OverflowAction='Wrap';





        VectorDataType='Same word length as input';







        CustomVectorDataType=numerictype([],16,15);




        ProductDataType='Full precision';







        CustomProductDataType=numerictype([],32,30);




        AccumulatorDataType='Full precision';







        CustomAccumulatorDataType=numerictype([],32,30);




        OutputDataType='Same as product';







        CustomOutputDataType=numerictype([],16,15);
    end

    properties(Constant,Hidden)
        VectorSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        VectorDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritFirst');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProdFirst');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeProdFirst');
    end

    methods

        function obj=ArrayVectorMultiplier(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:ArrayVectorMultiplier_NotSupported');
            obj@matlab.system.SFunSystem('mdspdmult2');
            setProperties(obj,nargin,varargin{:});
        end

        function set.CustomVectorDataType(obj,val)
            validateCustomDataType(obj,'CustomVectorDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomVectorDataType=val;
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

            VectorOptionIdx=getIndex(...
            obj.VectorSourceSet,obj.VectorSource);
            VectorOptionIdx=3-VectorOptionIdx;
            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                1,...
                obj.Dimension,...
                VectorOptionIdx,...
                obj.Vector,...
                [],[],...
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
                {'Vector','Product','Accumulator','Output'});

                obj.compSetParameters({...
                1,...
                obj.Dimension,...
                VectorOptionIdx,...
                obj.Vector,...
                [],[],...
                [],[],...
                dtInfo.VectorDataType,...
                dtInfo.VectorWordLength,...
                dtInfo.VectorFracLength,...
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

        function y=supportsUnboundedIO(~)
            y=true;
        end

    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'CustomVectorDataType'
                if(strcmp(obj.VectorSource,'Property')&&...
                    ~matlab.system.isSpecifiedTypeMode(obj.VectorDataType))||...
                    ~strcmp(obj.VectorSource,'Property')
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
            case 'CustomProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    flag=true;
                end
            case{'Vector','VectorDataType'}
                if~strcmp(obj.VectorSource,'Property')
                    flag=true;
                end
            end
        end

    end
    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.ArrayVectorMultiplier',dsp.ArrayVectorMultiplier.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspmtrx3/Array-Vector Multiply';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'Dimension'...
            ,'VectorSource'...
            ,'Vector'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'VectorDataType','CustomVectorDataType'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            ,'OutputDataType','CustomOutputDataType'...
            };
        end




        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Vector=3;
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
