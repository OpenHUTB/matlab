classdef PAMDemodulator<comm.internal.DemodulatorBase&comm.internal.ConstellationBase
















































































%#function mcompamdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)






        ModulationOrder=4;







        SymbolMapping='Gray';




        NormalizationMethod='Minimum distance between symbols';





        MinimumDistance=2;




        AveragePower=1;




        PeakPower=1;
    end

    properties(Nontunable)









        BitOutput=false;
    end



    properties(Nontunable)




        DenormalizationFactorDataType='Same word length as input';







        CustomDenormalizationFactorDataType=numerictype([],16);




        ProductDataType='Full precision';








        CustomProductDataType=numerictype([],32);





        ProductRoundingMethod='Floor';




        ProductOverflowAction='Wrap';





        SumDataType='Full precision';








        CustomSumDataType=numerictype([],32);










        FullPrecisionOverride(1,1)logical=true;
    end

    properties(Constant,Hidden)
        NormalizationMethodSet=comm.CommonSets.getSet(...
        'NormalizationMethods');
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');

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

        function obj=PAMDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.DemodulatorBase('mcompamdemod');
            setProperties(obj,nargin,varargin{:},'ModulationOrder');
        end

        function set.CustomDenormalizationFactorDataType(obj,val)
            validateCustomDataType(obj,'CustomDenormalizationFactorDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomDenormalizationFactorDataType=val;
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

            outputDataTypeBitIdx=getIndex(obj.pBitOutputDataTypeSet,...
            obj.OutputDataType);
            if isempty(outputDataTypeBitIdx)
                if obj.BitOutput
                    coder.internal.errorIf(true,'comm:system:PAMDemodulator:invalidOutputDataType',obj.OutputDataType);
                else
                    outputDataTypeBitIdx=1;
                end
            end

            outputDataTypeIntIdx=getIndex(obj.pIntOutputDataTypeSet,...
            obj.OutputDataType);
            if isempty(outputDataTypeIntIdx)
                if~obj.BitOutput
                    coder.internal.errorIf(true,'comm:system:PAMDemodulator:invalidOutputDataType',obj.OutputDataType);
                else
                    outputDataTypeIntIdx=1;
                end
            end

            denormalizationFactorDataTypeIdx=getIndex(...
            obj.DenormalizationFactorDataTypeSet,...
            obj.DenormalizationFactorDataType);

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
            normalizationMethodIdx,...
            obj.MinimumDistance,...
            obj.AveragePower,...
            obj.PeakPower,...
            outputDataTypeBitIdx,...
            outputDataTypeIntIdx,...
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
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)


            if strcmp(obj.OutputDataType,'Full precision')...
                &&isInputFloatingPoint(obj,1)
                setPortDataTypeConnection(obj,1,1);
            end

        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.PAMDemodulator',...
            comm.PAMDemodulator.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndam3/M-PAM Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ModulationOrder',...
            'BitOutput',...
            'SymbolMapping',...
            'NormalizationMethod',...
            'MinimumDistance',...
            'AveragePower',...
            'PeakPower',...
            'OutputDataType',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride',...
            'DenormalizationFactorDataType',...
            'CustomDenormalizationFactorDataType',...
            'ProductDataType',...
            'CustomProductDataType',...
            'ProductRoundingMethod',...
            'ProductOverflowAction',...
            'SumDataType',...
            'CustomSumDataType'};
        end


        function props=getValueOnlyProperties()
            props={'ModulationOrder'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end
