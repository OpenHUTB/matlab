classdef RectangularQAMDemodulator<comm.internal.DemodulatorSoftDecision&comm.internal.ConstellationBase






























































































%#function mcomqamdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)






        DecisionMethod='Hard decision';





        VarianceSource='Property';




        ModulationOrder=16;



        PhaseOffset=0;









        SymbolMapping='Gray';









        CustomSymbolMapping=0:15;




        NormalizationMethod='Minimum distance between symbols';





        MinimumDistance=2;




        AveragePower=1;




        PeakPower=1;










        DerotateFactorDataType='Same word length as input';







        CustomDerotateFactorDataType=numerictype([],16);






        DenormalizationFactorDataType='Same word length as input';







        CustomDenormalizationFactorDataType=numerictype([],16);






        ProductDataType='Full precision';








        CustomProductDataType=numerictype([],32);







        ProductRoundingMethod='Floor';






        ProductOverflowAction='Wrap';







        SumDataType='Full precision';








        CustomSumDataType=numerictype([],32);
    end

    properties(Nontunable,Logical)









        BitOutput=false;












        FullPrecisionOverride=true;
    end

    properties(Constant,Hidden)
        NormalizationMethodSet=comm.CommonSets.getSet('NormalizationMethods');
        SymbolMappingSet=comm.CommonSets.getSet('BinaryGrayCustom');
        DecisionMethodSet=comm.CommonSets.getSet('DecisionOptions');
        VarianceSourceSet=comm.CommonSets.getSet('SpecifyInputs');

        DerotateFactorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeUnscaled');
        DenormalizationFactorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeUnscaled');
        ProductDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInheritUnscaled');
        ProductRoundingMethodSet=dsp.CommonSets.getSet(...
        'RoundingMethod');
        ProductOverflowActionSet=dsp.CommonSets.getSet(...
        'OverflowAction');
        SumDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInheritProdUnscaled');
    end

    methods
        function obj=RectangularQAMDemodulator(varargin)
            warning(message('comm:shared:willBeRemovedReplacementRef',...
            'COMM.RECTANGULARQAMDEMODULATOR','QAMDEMOD',...
            'REMOVE_RectangularQAMModulator'));
            coder.allowpcode('plain');
            obj@comm.internal.DemodulatorSoftDecision('mcomqamdemod');
            setProperties(obj,nargin,varargin{:},'ModulationOrder');
        end

        function set.CustomDenormalizationFactorDataType(obj,val)
            validateCustomDataType(obj,'CustomDenormalizationFactorDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomDenormalizationFactorDataType=val;
        end

        function set.CustomDerotateFactorDataType(obj,val)
            validateCustomDataType(obj,'CustomDerotateFactorDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomDerotateFactorDataType=val;
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomProductDataType=val;
        end

        function set.CustomSumDataType(obj,val)
            validateCustomDataType(obj,'CustomSumDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomSumDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)
            outputFormatIdx=~obj.BitOutput+1;
            symbolMappingIdx=getIndex(obj.SymbolMappingSet,...
            obj.SymbolMapping);
            normalizationMethodIdx=getIndex(obj.NormalizationMethodSet,...
            obj.NormalizationMethod);
            decisionMethodIdx=getIndex(obj.DecisionMethodSet,obj.DecisionMethod);
            varianceSourceIdx=getIndex(obj.VarianceSourceSet,...
            obj.VarianceSource);

            outputDataTypeBitIdx=getIndex(obj.pBitOutputDataTypeSet,...
            obj.OutputDataType);
            if isempty(outputDataTypeBitIdx)
                if obj.BitOutput
                    coder.internal.errorIf(true,'comm:system:RectangularQAMDemodulator:invalidOutputDataType',obj.OutputDataType);
                else
                    outputDataTypeBitIdx=1;
                end
            end

            outputDataTypeIntIdx=getIndex(obj.pIntOutputDataTypeSet,...
            obj.OutputDataType);
            if isempty(outputDataTypeIntIdx)
                if~obj.BitOutput
                    coder.internal.errorIf(true,'comm:system:RectangularQAMDemodulator:invalidOutputDataType',obj.OutputDataType);
                else
                    outputDataTypeIntIdx=1;
                end
            end

            derotateFactorDataTypeIdx=getIndex(obj.DerotateFactorDataTypeSet,...
            obj.DerotateFactorDataType);
            denormalizationFactorDataTypeIdx=getIndex(...
            obj.DenormalizationFactorDataTypeSet,...
            obj.DenormalizationFactorDataType);

            if(symbolMappingIdx==3)
                status=commblkuserdefinedmapping(obj.ModulationOrder,obj.CustomSymbolMapping,true);
                if~isempty(status.identifier)
                    coder.internal.errorIf(true,status.identifier);
                end
            end

            if obj.FullPrecisionOverride

                prdDTMode=1;
                prdWLVal=32;
                prdRoundMode=3;
                prdOvrflMode=1;
                sumDTMode=1;
                sumWLVal=32;
            else
                prdDTMode=getIndex(obj.ProductDataTypeSet,obj.ProductDataType);
                prdWLVal=obj.CustomProductDataType.WordLength;
                prdRoundMode=getIndex(obj.ProductRoundingMethodSet,...
                obj.ProductRoundingMethod);
                prdOvrflMode=getIndex(obj.ProductOverflowActionSet,...
                obj.ProductOverflowAction);

                sumDTMode=getIndex(obj.SumDataTypeSet,obj.SumDataType);
                sumWLVal=obj.CustomSumDataType.WordLength;
            end










            obj.compSetParameters({...
            obj.ModulationOrder,...
            outputFormatIdx,...
            symbolMappingIdx,...
            obj.CustomSymbolMapping,...
            normalizationMethodIdx,...
            obj.MinimumDistance,...
            obj.AveragePower,...
            obj.PeakPower,...
            obj.PhaseOffset,...
            decisionMethodIdx,...
            varianceSourceIdx,...
            obj.Variance,...
            outputDataTypeBitIdx,...
            outputDataTypeIntIdx,...
            derotateFactorDataTypeIdx,...
            obj.CustomDerotateFactorDataType.WordLength,...
            denormalizationFactorDataTypeIdx,...
            obj.CustomDenormalizationFactorDataType.WordLength,...
            prdDTMode,...
            prdWLVal,...
            prdRoundMode,...
            prdOvrflMode,...
            sumDTMode,...
sumWLVal...
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            switch obj.NormalizationMethod
            case 'Minimum distance between symbols'
                props={'AveragePower','PeakPower'};
            case 'Average power'
                props={'MinimumDistance','PeakPower'};
            case 'Peak power'
                props={'MinimumDistance','AveragePower'};
            otherwise
                props={};
            end

            if~strcmp(obj.SymbolMapping,'Custom')
                props{end+1}='CustomSymbolMapping';
            end

            if~obj.BitOutput

                props(end+1:end+3)=[{'DecisionMethod'},{'VarianceSource'},...
                {'Variance'}];
            elseif strcmp(obj.DecisionMethod,'Hard decision')

                props(end+1:end+2)=[{'VarianceSource'},{'Variance'}];
            elseif strcmp(obj.VarianceSource,'Input port')


                props(end+1:end+2)=[{'Variance'},{'OutputDataType'}];
            else


                props{end+1}='OutputDataType';
            end



            if(obj.BitOutput&&~strcmp(obj.DecisionMethod,'Hard decision'))

                props=[props,{...
                'FullPrecisionOverride',...
                'DerotateFactorDataType','CustomDerotateFactorDataType',...
                'DenormalizationFactorDataType','CustomDenormalizationFactorDataType',...
                'ProductDataType','CustomProductDataType',...
                'ProductRoundingMethod','ProductOverflowAction',...
                'SumDataType','CustomSumDataType'}];
            else

                if~matlab.system.isSpecifiedTypeMode(obj.DerotateFactorDataType)
                    props{end+1}='CustomDerotateFactorDataType';
                end
                if~matlab.system.isSpecifiedTypeMode(obj.DenormalizationFactorDataType)
                    props{end+1}='CustomDenormalizationFactorDataType';
                end

                if obj.FullPrecisionOverride


                    props=[props,{
                    'ProductDataType',...
                    'CustomProductDataType',...
                    'ProductRoundingMethod',...
                    'ProductOverflowAction',...
                    'SumDataType',...
                    'CustomSumDataType'}];
                else

                    if strcmpi(obj.ProductDataType,'Full precision')
                        props=[props,{
                        'CustomProductDataType',...
                        'ProductRoundingMethod',...
                        'ProductOverflowAction'}];




                    end

                    if~matlab.system.isSpecifiedTypeMode(obj.SumDataType)
                        props{end+1}='CustomSumDataType';
                    end
                end
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.RectangularQAMDemodulator',...
            comm.RectangularQAMDemodulator.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndam3/Rectangular QAM Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'PhaseOffset',...
            'BitOutput',...
            'SymbolMapping',...
            'CustomSymbolMapping',...
            'NormalizationMethod',...
            'MinimumDistance',...
            'AveragePower',...
            'PeakPower',...
            'DecisionMethod',...
            'VarianceSource',...
            'Variance',...
            'OutputDataType',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride',...
            'DerotateFactorDataType',...
            'CustomDerotateFactorDataType',...
            'DenormalizationFactorDataType',...
            'CustomDenormalizationFactorDataType',...
            'ProductDataType',...
            'CustomProductDataType',...
            'ProductRoundingMethod',...
            'ProductOverflowAction',...
            'SumDataType',...
            'CustomSumDataType'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Variance=11;
        end


        function props=getValueOnlyProperties()
            props={'ModulationOrder'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end

