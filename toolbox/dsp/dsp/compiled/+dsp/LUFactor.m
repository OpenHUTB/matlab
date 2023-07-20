classdef LUFactor<matlab.system.SFunSystem




















































%#function mdsplu2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)






        RoundingMethod='Floor';


        OverflowAction='Wrap';



        ProductDataType='Full precision';







        CustomProductDataType=numerictype([],32,30);



        AccumulatorDataType='Full precision';







        CustomAccumulatorDataType=numerictype([],32,30);



        OutputDataType='Same as input';







        CustomOutputDataType=numerictype([],16,15);






        ExceptionOutputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
    end

    methods
        function obj=LUFactor(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:LUFactor_NotSupported');
            obj@matlab.system.SFunSystem('mdsplu2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
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
                double(obj.ExceptionOutputPort),...
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
                1});
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'Product','Accumulator','Output'});
                obj.compSetParameters({...
                double(obj.ExceptionOutputPort),...
                1,...
                [],...
                [],...
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
            flag=false;
            switch prop
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






            matlab.system.dispFixptHelp('dsp.LUFactor',...
            dsp.LUFactor.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspfactors/LU Factorization';
        end

        function props=getDisplayPropertiesImpl()
            props={'ExceptionOutputPort'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'RoundingMethod','OverflowAction',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType'};
        end

    end
    methods(Access=protected)
        function setPortDataTypeConnections(obj)

            setPortDataTypeConnection(obj,1,1);

            if isInputFloatingPoint(obj,1)
                setPortDataTypeConnection(obj,1,2);
            end
        end
    end
end
