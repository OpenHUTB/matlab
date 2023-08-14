classdef LDLFactor<matlab.system.SFunSystem












































%#function mdspldl2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)






        RoundingMethod='Floor';



        OverflowAction='Wrap';



        IntermediateProductDataType='Same as input';







        CustomIntermediateProductDataType=numerictype([],16,15);




        ProductDataType='Full precision';







        CustomProductDataType=numerictype([],32,30);




        AccumulatorDataType='Full precision';







        CustomAccumulatorDataType=numerictype([],32,30);



        OutputDataType='Same as input';







        CustomOutputDataType=numerictype([],16,15);
    end
    properties(Constant,Hidden)


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        IntermediateProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
    end

    methods

        function obj=LDLFactor(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:LDLFactor_NotSupported');
            obj@matlab.system.SFunSystem('mdspldl2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
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

    methods(Hidden)

        function setParameters(obj)


            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                1,...
                [],...
                [],...
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

                obj.compSetParameters({...
                1,...
                [],...
                [],...
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

    methods(Access=protected)


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
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
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.LDLFactor',dsp.LDLFactor.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspfactors/LDL Factorization';
        end

        function props=getDisplayPropertiesImpl()
            props={};
        end
        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'IntermediateProductDataType','CustomIntermediateProductDataType'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            ,'OutputDataType','CustomOutputDataType'...
            };
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


