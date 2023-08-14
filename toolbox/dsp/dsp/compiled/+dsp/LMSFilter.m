classdef LMSFilter<matlab.system.SFunSystem



















































































































































%#function mdsplms

%#ok<*EMCLS>
%#ok<*EMCA>

    properties






        StepSize=0.1;






        LeakageFactor=1.0;
    end

    properties(Nontunable)




        Method='LMS';



        Length=32;



        StepSizeSource='Property';




        InitialConditions=0;







        WeightsResetCondition='Non-zero';







        RoundingMethod='Floor';



        OverflowAction='Wrap';





        StepSizeDataType='Same word length as first input';







        CustomStepSizeDataType=numerictype([],16,15);




        LeakageFactorDataType='Same word length as first input';







        CustomLeakageFactorDataType=numerictype([],16,15);



        WeightsDataType='Same as first input';







        CustomWeightsDataType=numerictype([],16,15);




        EnergyProductDataType='Same as first input';








        CustomEnergyProductDataType=numerictype([],32,20);




        EnergyAccumulatorDataType='Same as first input';








        CustomEnergyAccumulatorDataType=numerictype([],32,20);




        ConvolutionProductDataType='Same as first input';







        CustomConvolutionProductDataType=numerictype([],32,20);




        ConvolutionAccumulatorDataType='Same as first input';







        CustomConvolutionAccumulatorDataType=numerictype([],32,20);




        StepSizeErrorProductDataType='Same as first input';







        CustomStepSizeErrorProductDataType=numerictype([],32,20);




        WeightsUpdateProductDataType='Same as first input';







        CustomWeightsUpdateProductDataType=numerictype([],32,20);




        QuotientDataType='Same as first input';








        CustomQuotientDataType=numerictype([],32,20);









        AdaptInputPort(1,1)logical=false;








        WeightsResetInputPort(1,1)logical=false;
    end

    properties(Nontunable,Hidden)



        WeightsOutputPort=true;
    end

    properties(Dependent,Nontunable)










        WeightsOutput='Last';%#ok<MDEPIN>
    end

    properties(Constant,Hidden)

        MethodSet=matlab.system.StringSet({...
        'LMS',...
        'Normalized LMS',...
        'Sign-Error LMS',...
        'Sign-Data LMS',...
        'Sign-Sign LMS'});
        StepSizeSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        WeightsResetConditionSet=dsp.CommonSets.getSet(...
        'ResetCondition');
        WeightsOutputSet=matlab.system.StringSet({...
        'None',...
        'Last',...
        'All'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        StepSizeDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeEitherScaleFirst');
        LeakageFactorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeEitherScaleFirst');
        WeightsDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
        EnergyProductDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
        EnergyAccumulatorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
        ConvolutionProductDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
        ConvolutionAccumulatorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
        StepSizeErrorProductDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
        WeightsUpdateProductDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
        QuotientDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeBasicFirst');
    end

    methods

        function obj=LMSFilter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdsplms');
            setProperties(obj,nargin,varargin{:},'Length');
            setEmptyAllowedStatus(obj,true);
        end
        function set.WeightsOutput(obj,val)
            switch(val)
            case 'None'
                obj.WeightsOutputPort=false;
            case 'All'
                obj.WeightsOutputPort=[];
            otherwise

                obj.WeightsOutputPort=true;
            end
        end
        function val=get.WeightsOutput(obj)
            if isempty(obj.WeightsOutputPort)
                val='All';
            elseif~(obj.WeightsOutputPort)
                val='None';
            else
                val='Last';
            end
        end
        function set.CustomStepSizeDataType(obj,val)
            validateCustomDataType(obj,'CustomStepSizeDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomStepSizeDataType=val;
        end
        function set.CustomLeakageFactorDataType(obj,val)
            validateCustomDataType(obj,'CustomLeakageFactorDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomLeakageFactorDataType=val;
        end
        function set.CustomWeightsDataType(obj,val)
            validateCustomDataType(obj,'CustomWeightsDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomWeightsDataType=val;
        end
        function set.CustomEnergyProductDataType(obj,val)
            validateCustomDataType(obj,'CustomEnergyProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomEnergyProductDataType=val;
        end
        function set.CustomEnergyAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomEnergyAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomEnergyAccumulatorDataType=val;
        end
        function set.CustomConvolutionProductDataType(obj,val)
            validateCustomDataType(obj,'CustomConvolutionProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomConvolutionProductDataType=val;
        end
        function set.CustomConvolutionAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomConvolutionAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomConvolutionAccumulatorDataType=val;
        end
        function set.CustomStepSizeErrorProductDataType(obj,val)
            validateCustomDataType(obj,'CustomStepSizeErrorProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomStepSizeErrorProductDataType=val;
        end
        function set.CustomWeightsUpdateProductDataType(obj,val)
            validateCustomDataType(obj,'CustomWeightsUpdateProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomWeightsUpdateProductDataType=val;
        end
        function set.CustomQuotientDataType(obj,val)
            validateCustomDataType(obj,'CustomQuotientDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomQuotientDataType=val;
        end

        function[mumax,mumaxmse]=maxstep(obj,x)













            [mumax,mumaxmse]=dsp.internal.maxstep(obj,x);
        end

        function[mmse,emse,meanW,mse,traceK]=msepred(obj,varargin)































            if nargout<=2
                [mmse,emse]=dsp.internal.msepred(obj,varargin{:});
            else
                [mmse,emse,meanW,mse,traceK]=dsp.internal.msepred(obj,varargin{:});
            end
        end

        function[mse,meanW,W,traceK]=msesim(obj,varargin)




































            [mse,meanW,W,traceK]=dsp.internal.msesim(obj,varargin{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)

            MethodIdx=getIndex(obj.MethodSet,obj.Method);
            StepSizeSourceIdx=getIndex(obj.StepSizeSourceSet,...
            obj.StepSizeSource);
            WeightsOutputIdx=getIndex(obj.WeightsOutputSet,...
            obj.WeightsOutput);
            if obj.WeightsResetInputPort
                WeightsResetIdx=getIndex(obj.WeightsResetConditionSet,...
                obj.WeightsResetCondition);
            else
                WeightsResetIdx=0;
            end
            AdaptWeightsIdx=double(obj.AdaptInputPort);

            ic=flipud(obj.InitialConditions(:));

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                MethodIdx,...
                obj.Length,...
                StepSizeSourceIdx,...
                obj.StepSize,...
                obj.LeakageFactor,...
                ic,...
                AdaptWeightsIdx,...
                WeightsResetIdx,...
                (WeightsOutputIdx-1),...
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
                dtInfo=getFixptDataTypeInfo(obj,...
                {'StepSize',...
                'LeakageFactor',...
                'Weights',...
                'EnergyProduct',...
                'EnergyAccumulator',...
                'ConvolutionProduct',...
                'ConvolutionAccumulator',...
                'StepSizeErrorProduct',...
                'WeightsUpdateProduct',...
                'Quotient'});

                obj.compSetParameters({...
                MethodIdx,...
                obj.Length,...
                StepSizeSourceIdx,...
                obj.StepSize,...
                obj.LeakageFactor,...
                ic,...
                AdaptWeightsIdx,...
                WeightsResetIdx,...
                (WeightsOutputIdx-1),...
                dtInfo.StepSizeDataType,...
                dtInfo.StepSizeWordLength,...
                dtInfo.StepSizeFracLength,...
                dtInfo.LeakageFactorDataType,...
                dtInfo.LeakageFactorWordLength,...
                dtInfo.LeakageFactorFracLength,...
                dtInfo.EnergyProductDataType,...
                dtInfo.EnergyProductWordLength,...
                dtInfo.EnergyProductFracLength,...
                dtInfo.ConvolutionProductDataType,...
                dtInfo.ConvolutionProductWordLength,...
                dtInfo.ConvolutionProductFracLength,...
                dtInfo.StepSizeErrorProductDataType,...
                dtInfo.StepSizeErrorProductWordLength,...
                dtInfo.StepSizeErrorProductFracLength,...
                dtInfo.WeightsUpdateProductDataType,...
                dtInfo.WeightsUpdateProductWordLength,...
                dtInfo.WeightsUpdateProductFracLength,...
                dtInfo.QuotientDataType,...
                dtInfo.QuotientWordLength,...
                dtInfo.QuotientFracLength,...
                dtInfo.EnergyAccumulatorDataType,...
                dtInfo.EnergyAccumulatorWordLength,...
                dtInfo.EnergyAccumulatorFracLength,...
                dtInfo.ConvolutionAccumulatorDataType,...
                dtInfo.ConvolutionAccumulatorWordLength,...
                dtInfo.ConvolutionAccumulatorFracLength,...
                dtInfo.WeightsDataType,...
                dtInfo.WeightsWordLength,...
                dtInfo.WeightsFracLength,...
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
            case 'WeightsResetCondition'
                if~obj.WeightsResetInputPort
                    flag=true;
                end
            case{'EnergyProductDataType','EnergyAccumulatorDataType','QuotientDataType'}
                if~strcmp(obj.Method,'Normalized LMS')
                    flag=true;
                end
            case 'CustomEnergyProductDataType'
                if~strcmp(obj.Method,'Normalized LMS')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.EnergyProductDataType)
                    flag=true;
                end
            case 'CustomEnergyAccumulatorDataType'
                if~strcmp(obj.Method,'Normalized LMS')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.EnergyAccumulatorDataType)
                    flag=true;
                end
            case 'CustomQuotientDataType'
                if~strcmp(obj.Method,'Normalized LMS')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.QuotientDataType)
                    flag=true;
                end
            case{'StepSize','StepSizeDataType'}
                if strcmp(obj.StepSizeSource,'Input port')
                    flag=true;
                end
            case 'CustomStepSizeDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.StepSizeDataType)
                    flag=true;
                end
            case 'CustomLeakageFactorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.LeakageFactorDataType)
                    flag=true;
                end
            case 'CustomWeightsDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.WeightsDataType)
                    flag=true;
                end
            case 'CustomConvolutionProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.ConvolutionProductDataType)
                    flag=true;
                end
            case 'CustomConvolutionAccumulatorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.ConvolutionAccumulatorDataType)
                    flag=true;
                end
            case 'CustomStepSizeErrorProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.StepSizeErrorProductDataType)
                    flag=true;
                end
            case 'CustomWeightsUpdateProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.WeightsUpdateProductDataType)
                    flag=true;
                end
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.LMSFilter',...
            dsp.LMSFilter.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspadpt3/LMS Filter';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'Method'...
            ,'Length'...
            ,'StepSizeSource'...
            ,'StepSize'...
            ,'LeakageFactor'...
            ,'InitialConditions'...
            ,'AdaptInputPort'...
            ,'WeightsResetInputPort'...
            ,'WeightsResetCondition',...
'WeightsOutput'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'StepSizeDataType','CustomStepSizeDataType'...
            ,'LeakageFactorDataType','CustomLeakageFactorDataType'...
            ,'WeightsDataType','CustomWeightsDataType'...
            ,'EnergyProductDataType','CustomEnergyProductDataType'...
            ,'EnergyAccumulatorDataType','CustomEnergyAccumulatorDataType'...
            ,'ConvolutionProductDataType','CustomConvolutionProductDataType'...
            ,'ConvolutionAccumulatorDataType','CustomConvolutionAccumulatorDataType'...
            ,'StepSizeErrorProductDataType','CustomStepSizeErrorProductDataType'...
            ,'WeightsUpdateProductDataType','CustomWeightsUpdateProductDataType'...
            ,'QuotientDataType','CustomQuotientDataType'...
            };
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.StepSize=3;
            tunePropsMap.LeakageFactor=4;
        end


        function props=getValueOnlyProperties()
            props={'Length'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)

            hasWeightsOutput=~strcmp(obj.WeightsOutput,'None');

            if isInputFloatingPoint(obj,1)
                setPortDataTypeConnection(obj,1,1);
                setPortDataTypeConnection(obj,1,2);
                if hasWeightsOutput
                    setPortDataTypeConnection(obj,1,3);
                end
            else
                setPortDataTypeConnection(obj,2,1);
                setPortDataTypeConnection(obj,2,2);
                if hasWeightsOutput



                    setPortDataTypeConnection(obj,2,3);
                end
            end
        end
    end
end
