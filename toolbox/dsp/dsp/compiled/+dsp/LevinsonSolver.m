classdef LevinsonSolver<matlab.system.SFunSystem































































%#function mdsplevdurb2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        ZerothLagZeroAction='Use zeros';







        RoundingMethod='Floor';



        OverflowAction='Wrap';



        ACoefficientDataType='Custom';






        CustomACoefficientDataType=numerictype([],16,15);



        KCoefficientDataType='Custom';






        CustomKCoefficientDataType=numerictype([],16,15);




        PredictionErrorDataType='Same as input';








        CustomPredictionErrorDataType=numerictype([],16,15);



        ProductDataType='Custom';







        CustomProductDataType=numerictype([],32,30);



        AccumulatorDataType='Custom';







        CustomAccumulatorDataType=numerictype([],32,30);






        AOutputPort(1,1)logical=false;





        KOutputPort(1,1)logical=true;



        PredictionErrorOutputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        ZerothLagZeroActionSet=matlab.system.StringSet({'Ignore','Use zeros'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ACoefficientDataTypeSet=dsp.CommonSets.getSet('FixptModeScaledOnly');
        KCoefficientDataTypeSet=dsp.CommonSets.getSet('FixptModeScaledOnly');
        PredictionErrorDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProd');
    end

    methods
        function obj=LevinsonSolver(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:LevinsonSolver_NotSupported');
            obj@matlab.system.SFunSystem('mdsplevdurb2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomACoefficientDataType(obj,val)
            validateCustomDataType(obj,'CustomACoefficientDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomACoefficientDataType=val;
        end

        function set.CustomKCoefficientDataType(obj,val)
            validateCustomDataType(obj,'CustomKCoefficientDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomKCoefficientDataType=val;
        end

        function set.CustomPredictionErrorDataType(obj,val)
            validateCustomDataType(obj,'CustomPredictionErrorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomPredictionErrorDataType=val;
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
    end

    methods(Hidden)
        function setParameters(obj)

            coder.internal.errorIf(~obj.AOutputPort&&~obj.KOutputPort,...
            'dsp:system:LevinsonSolver:noOutputsSpecified');

            OutputCoefficientIdx=4-2*obj.AOutputPort-obj.KOutputPort;
            ZerothLagZeroActionIdx=getIndex(...
            obj.ZerothLagZeroActionSet,obj.ZerothLagZeroAction);

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                OutputCoefficientIdx,...
                double(obj.PredictionErrorOutputPort),...
                ZerothLagZeroActionIdx-1,...
                4,...
                [],[],...
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
                2,...
                2,...
                2,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,{'ACoefficient',...
                'KCoefficient','PredictionError','Product','Accumulator'});
                obj.compSetParameters({...
                OutputCoefficientIdx,...
                double(obj.PredictionErrorOutputPort),...
                ZerothLagZeroActionIdx-1,...
                4,...
                [],[],...
                [],[],...
                [],[],...
                dtInfo.ACoefficientDataType,...
                dtInfo.ACoefficientWordLength,...
                dtInfo.ACoefficientFracLength,...
                dtInfo.KCoefficientDataType,...
                dtInfo.KCoefficientWordLength,...
                dtInfo.KCoefficientFracLength,...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.PredictionErrorDataType,...
                dtInfo.PredictionErrorWordLength,...
                dtInfo.PredictionErrorFracLength,...
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
            case 'CustomACoefficientDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.ACoefficientDataType)
                    flag=true;
                end
            case 'CustomKCoefficientDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.KCoefficientDataType)
                    flag=true;
                end
            case 'CustomPredictionErrorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.PredictionErrorDataType)
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
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.LevinsonSolver',...
            dsp.LevinsonSolver.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsolvers/Levinson-Durbin';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'AOutputPort'...
            ,'KOutputPort'...
            ,'PredictionErrorOutputPort'...
            ,'ZerothLagZeroAction'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'ACoefficientDataType','CustomACoefficientDataType'...
            ,'KCoefficientDataType','CustomKCoefficientDataType'...
            ,'PredictionErrorDataType','CustomPredictionErrorDataType'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            };
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            for ii=1:getNumOutputs(obj)
                setPortDataTypeConnection(obj,1,ii);
            end
        end
    end
end
