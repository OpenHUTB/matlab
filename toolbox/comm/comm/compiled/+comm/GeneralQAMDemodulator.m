classdef GeneralQAMDemodulator<matlab.system.SFunSystem





















































































%#function mcomgenqamdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties









        Variance=1;
    end

    properties(Nontunable)










        BitOutput(1,1)logical=false;












        Constellation=exp(2*pi*1i*(0:7)/8);






        DecisionMethod='Hard decision';




        VarianceSource='Property';




























        OutputDataType='Full precision';









        RoundingMethod='Floor';







        OverflowAction='Wrap';






        ConstellationDataType='Same word length as input';







        CustomConstellationDataType=numerictype([],16);






        Accumulator1DataType='Full precision';








        CustomAccumulator1DataType=numerictype([],32,30);





        ProductInputDataType='Same as accumulator 1';








        CustomProductInputDataType=numerictype([],32,30);





        ProductOutputDataType='Full precision';








        CustomProductOutputDataType=numerictype([],32,30);





        Accumulator2DataType='Full precision';








        CustomAccumulator2DataType=numerictype([],32,30);





        Accumulator3DataType='Full precision';








        CustomAccumulator3DataType=numerictype([],32,30);





        NoiseScalingInputDataType='Same as accumulator 3';









        CustomNoiseScalingInputDataType=numerictype([],32,30);






        InverseVarianceDataType='Same word length as input';







        CustomInverseVarianceDataType=numerictype([],16,8);








        CustomOutputDataType=numerictype([],32,30);













        FullPrecisionOverride(1,1)logical=true;
    end

    properties(Constant,Hidden)
        DecisionMethodSet=comm.CommonSets.getSet('DecisionOptions');
        VarianceSourceSet=comm.CommonSets.getSet('SpecifyInputs');

        pIntOutputDataTypeSet=comm.CommonSets.getSet('IntDataType');
        pBitOutputDataTypeSet=comm.CommonSets.getSet('BitDataType');
        pFxPtOutputDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInheritUnscaled');


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction')
        ConstellationDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeUnscaled');
        Accumulator1DataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInheritUnscaled');
        ProductInputDataTypeSet=matlab.system.StringSet(...
        {'Same as accumulator 1',matlab.system.getSpecifyString('scaled')});
        ProductOutputDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInheritUnscaled');
        Accumulator2DataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInheritUnscaled');
        Accumulator3DataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInheritUnscaled');
        NoiseScalingInputDataTypeSet=matlab.system.StringSet(...
        {'Same as accumulator 3',matlab.system.getSpecifyString('scaled')});
        InverseVarianceDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeEitherScale');
    end

    properties(Transient,Hidden)
pIntOutputDataType
pBitOutputDataType
pFxPtOutputDataType
    end
    properties(Transient,Hidden)
        OutputDataTypeSet=comm.CommonSets.getSet('IntDataType');
    end

    methods
        function obj=GeneralQAMDemodulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomgenqamdemod');
            setProperties(obj,nargin,varargin{:},'Constellation');
            setForceInputRealToComplex(obj,1,true);
        end

        function set.CustomConstellationDataType(obj,val)
            validateCustomDataType(obj,'CustomConstellationDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomConstellationDataType=val;
        end

        function set.CustomInverseVarianceDataType(obj,val)
            validateCustomDataType(obj,'CustomInverseVarianceDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomInverseVarianceDataType=val;
        end

        function set.CustomAccumulator1DataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulator1DataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulator1DataType=val;
        end

        function set.CustomProductInputDataType(obj,val)
            validateCustomDataType(obj,'CustomProductInputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductInputDataType=val;
        end

        function set.CustomProductOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomProductOutputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductOutputDataType=val;
        end

        function set.CustomAccumulator2DataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulator2DataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulator2DataType=val;
        end

        function set.CustomAccumulator3DataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulator3DataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulator3DataType=val;
        end

        function set.CustomNoiseScalingInputDataType(obj,val)
            validateCustomDataType(obj,'CustomNoiseScalingInputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomNoiseScalingInputDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomOutputDataType=val;
        end


        function set.Constellation(obj,val)
            validateattributes(val,{'double'},{},'','Constellation');obj.Constellation=val;
        end

        function value=get.OutputDataTypeSet(obj)
            if isFxPtOutputDataType(obj)


                value=obj.pFxPtOutputDataTypeSet;
            elseif obj.BitOutput&&(~strcmp(obj.DecisionMethod,'Approximate log-likelihood ratio'))


                value=obj.pBitOutputDataTypeSet;
            else

                value=obj.pIntOutputDataTypeSet;
            end
        end

        function set.OutputDataTypeSet(~,~)
        end
    end

    methods(Hidden)
        function setParameters(obj)
            bitOutputIdx=~obj.BitOutput+1;
            decisionMethodIdx=getIndex(obj.DecisionMethodSet,...
            obj.DecisionMethod);
            varianceSourceIdx=getIndex(obj.VarianceSourceSet,...
            obj.VarianceSource);
            constellationDataTypeIdx=getIndex(obj.ConstellationDataTypeSet,...
            obj.ConstellationDataType);
            noiseScalingInputDataTypeIdx=getIndex(...
            obj.NoiseScalingInputDataTypeSet,obj.NoiseScalingInputDataType);
            inverseVarianceDataTypeIdx=getIndex(...
            obj.InverseVarianceDataTypeSet,obj.InverseVarianceDataType);
            if inverseVarianceDataTypeIdx>1
                inverseVarianceDataTypeIdx=inverseVarianceDataTypeIdx+...
                strcmp(obj.CustomInverseVarianceDataType.Scaling,'BinaryPoint');
            end

            fpoApplies=true;

            if obj.BitOutput
                outputDataTypeIntIdx=1;
                outputDataTypeBitIdx=getIndex(obj.pBitOutputDataTypeSet,...
                obj.OutputDataType);

                if isempty(outputDataTypeBitIdx)

                    if(isequal(obj.DecisionMethod,'Approximate log-likelihood ratio')&&...
                        strcmp(obj.OutputDataType,'Custom'))

                        outputDataTypeBitIdx=2;
                    elseif~isequal(obj.DecisionMethod,'Log-likelihood ratio')
                        coder.internal.errorIf(true,'comm:system:GeneralQAMDemodulator:invalidOutputDataType',obj.OutputDataType);
                    else
                        outputDataTypeBitIdx=1;
                    end
                end

                if strcmp(obj.DecisionMethod,'Approximate log-likelihood ratio')


                    fpoApplies=false;
                end
            else

                outputDataTypeBitIdx=1;
                outputDataTypeIntIdx=getIndex(obj.pIntOutputDataTypeSet,...
                obj.OutputDataType);

                coder.internal.errorIf(isempty(outputDataTypeIntIdx),'comm:system:GeneralQAMDemodulator:invalidOutputDataType',obj.OutputDataType);
            end

            if fpoApplies&&(obj.FullPrecisionOverride)

                roundingMethodIdx=3;
                overflowActionIdx=1;
                unusedWLDefault=32;
                unusedFLDefault=16;
                accumulator1DataTypeIdx=1;
                accumulator1WordLength=unusedWLDefault;
                accumulator1FracLength=unusedFLDefault;
                productInputDataTypeIdx=1;
                productInputWordLength=unusedWLDefault;
                productInputFracLength=unusedFLDefault;
                productOutputDataTypeIdx=1;
                productOutputWordLength=unusedWLDefault;
                productOutputFracLength=unusedFLDefault;
                accumulator2DataTypeIdx=1;
                accumulator2WordLength=unusedWLDefault;
                accumulator2FracLength=unusedFLDefault;
                accumulator3DataTypeIdx=1;
                accumulator3WordLength=unusedWLDefault;
                accumulator3FracLength=unusedFLDefault;
                noiseScalingInputDataTypeIdx=1;
                noiseScalingInputWordLength=unusedWLDefault;
                noiseScalingInputFracLength=unusedFLDefault;
                outputDataTypeFxPtIdx=1;
                outputWordLength=unusedWLDefault;
                outputFracLength=unusedFLDefault;
            else
                roundingMethodIdx=getIndex(obj.RoundingMethodSet,...
                obj.RoundingMethod);
                overflowActionIdx=getIndex(obj.OverflowActionSet,...
                obj.OverflowAction);

                accumulator1DataTypeIdx=getIndex(obj.Accumulator1DataTypeSet,...
                obj.Accumulator1DataType);
                accumulator1WordLength=obj.CustomAccumulator1DataType.WordLength;
                accumulator1FracLength=obj.CustomAccumulator1DataType.FractionLength;

                productInputDataTypeIdx=getIndex(obj.ProductInputDataTypeSet,...
                obj.ProductInputDataType);
                productInputWordLength=obj.CustomProductInputDataType.WordLength;
                productInputFracLength=obj.CustomProductInputDataType.FractionLength;

                productOutputDataTypeIdx=getIndex(obj.ProductOutputDataTypeSet,...
                obj.ProductOutputDataType);
                productOutputWordLength=obj.CustomProductOutputDataType.WordLength;
                productOutputFracLength=obj.CustomProductOutputDataType.FractionLength;

                accumulator2DataTypeIdx=getIndex(obj.Accumulator2DataTypeSet,...
                obj.Accumulator2DataType);
                accumulator2WordLength=obj.CustomAccumulator2DataType.WordLength;
                accumulator2FracLength=obj.CustomAccumulator2DataType.FractionLength;

                accumulator3DataTypeIdx=getIndex(obj.Accumulator3DataTypeSet,...
                obj.Accumulator3DataType);
                accumulator3WordLength=obj.CustomAccumulator3DataType.WordLength;
                accumulator3FracLength=obj.CustomAccumulator3DataType.FractionLength;

                noiseScalingInputWordLength=obj.CustomNoiseScalingInputDataType.WordLength;
                noiseScalingInputFracLength=obj.CustomNoiseScalingInputDataType.FractionLength;

                outputDataTypeFxPtIdx=getIndex(obj.pFxPtOutputDataTypeSet,...
                obj.OutputDataType);
                if isempty(outputDataTypeFxPtIdx)
                    outputDataTypeFxPtIdx=1;

                    coder.internal.errorIf(isFxPtOutputDataType(obj),'comm:system:GeneralQAMDemodulator:invalidOutputDataType',obj.OutputDataType);
                end

                outputWordLength=obj.CustomOutputDataType.WordLength;
                outputFracLength=obj.CustomOutputDataType.FractionLength;
            end










            obj.compSetParameters({...
            real(obj.Constellation),...
            imag(obj.Constellation),...
            bitOutputIdx,...
            decisionMethodIdx,...
            varianceSourceIdx,...
            obj.Variance,...
            outputDataTypeBitIdx,...
            outputDataTypeIntIdx,...
            roundingMethodIdx,...
            overflowActionIdx,...
            constellationDataTypeIdx,...
            obj.CustomConstellationDataType.WordLength,...
            accumulator1DataTypeIdx,...
            accumulator1WordLength,...
            accumulator1FracLength,...
            productInputDataTypeIdx,...
            productInputWordLength,...
            productInputFracLength,...
            productOutputDataTypeIdx,...
            productOutputWordLength,...
            productOutputFracLength,...
            accumulator2DataTypeIdx,...
            accumulator2WordLength,...
            accumulator2FracLength,...
            accumulator3DataTypeIdx,...
            accumulator3WordLength,...
            accumulator3FracLength,...
            noiseScalingInputDataTypeIdx,...
            noiseScalingInputWordLength,...
            noiseScalingInputFracLength,...
            inverseVarianceDataTypeIdx,...
            obj.CustomInverseVarianceDataType.WordLength,...
            obj.CustomInverseVarianceDataType.FractionLength,...
            outputDataTypeFxPtIdx,...
            outputWordLength,...
outputFracLength...
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            if~obj.BitOutput



                props={...
                'DecisionMethod',...
                'VarianceSource',...
                'Variance',...
...
                'Accumulator3DataType','CustomAccumulator3DataType',...
                'NoiseScalingInputDataType','CustomNoiseScalingInputDataType',...
                'InverseVarianceDataType','CustomInverseVarianceDataType',...
'CustomOutputDataType'...
                };


                if~matlab.system.isSpecifiedTypeMode(obj.ConstellationDataType)
                    props{end+1}='CustomConstellationDataType';
                end

                if obj.FullPrecisionOverride


                    props=[props,...
                    'RoundingMethod','OverflowAction',...
                    'Accumulator1DataType','CustomAccumulator1DataType',...
                    'ProductInputDataType','CustomProductInputDataType',...
                    'ProductOutputDataType','CustomProductOutputDataType',...
                    'Accumulator2DataType','CustomAccumulator2DataType'];
                else
                    if(strcmp(obj.Accumulator1DataType,'Full precision')&&...
                        strcmp(obj.ProductInputDataType,'Same as accumulator 1')&&...
                        strcmp(obj.ProductOutputDataType,'Full precision')&&...
                        strcmp(obj.Accumulator2DataType,'Full precision'))

                        props{end+1}='RoundingMethod';
                        props{end+1}='OverflowAction';
                    end


                    if~matlab.system.isSpecifiedTypeMode(obj.Accumulator1DataType)
                        props{end+1}='CustomAccumulator1DataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.ProductInputDataType)
                        props{end+1}='CustomProductInputDataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.ProductOutputDataType)
                        props{end+1}='CustomProductOutputDataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.Accumulator2DataType)
                        props{end+1}='CustomAccumulator2DataType';
                    end
                end

            else

                if strcmp(obj.DecisionMethod,'Hard decision')



                    props={...
                    'VarianceSource',...
'Variance'...
...
                    ,'Accumulator3DataType','CustomAccumulator3DataType',...
                    'NoiseScalingInputDataType','CustomNoiseScalingInputDataType',...
                    'InverseVarianceDataType','CustomInverseVarianceDataType',...
'CustomOutputDataType'...
                    };


                    if~matlab.system.isSpecifiedTypeMode(obj.ConstellationDataType)
                        props{end+1}='CustomConstellationDataType';
                    end

                    if obj.FullPrecisionOverride
                        props=[props,...
                        'RoundingMethod','OverflowAction',...
                        'Accumulator1DataType','CustomAccumulator1DataType',...
                        'ProductInputDataType','CustomProductInputDataType',...
                        'ProductOutputDataType','CustomProductOutputDataType',...
                        'Accumulator2DataType','CustomAccumulator2DataType'];

                    else
                        if(strcmp(obj.Accumulator1DataType,'Full precision')&&...
                            strcmp(obj.ProductInputDataType,'Same as accumulator 1')&&...
                            strcmp(obj.ProductOutputDataType,'Full precision')&&...
                            strcmp(obj.Accumulator2DataType,'Full precision'))

                            props{end+1}='RoundingMethod';
                            props{end+1}='OverflowAction';
                        end


                        if~matlab.system.isSpecifiedTypeMode(obj.Accumulator1DataType)
                            props{end+1}='CustomAccumulator1DataType';
                        end
                        if~matlab.system.isSpecifiedTypeMode(obj.ProductInputDataType)
                            props{end+1}='CustomProductInputDataType';
                        end
                        if~matlab.system.isSpecifiedTypeMode(obj.ProductOutputDataType)
                            props{end+1}='CustomProductOutputDataType';
                        end
                        if~matlab.system.isSpecifiedTypeMode(obj.Accumulator2DataType)
                            props{end+1}='CustomAccumulator2DataType';
                        end
                        if~matlab.system.isSpecifiedTypeMode(obj.Accumulator3DataType)
                            props{end+1}='CustomAccumulator3DataType';
                        end
                        if~matlab.system.isSpecifiedTypeMode(obj.NoiseScalingInputDataType)
                            props{end+1}='CustomNoiseScalingInputDataType';
                        end
                    end
                elseif strcmp(obj.DecisionMethod,'Log-likelihood ratio')



                    if strcmp(obj.VarianceSource,'Input port')
                        props={'Variance'};
                    else
                        props={};
                    end

                    props=[props,...
                    {'FullPrecisionOverride',...
                    'RoundingMethod','OverflowAction',...
                    'ConstellationDataType','CustomConstellationDataType',...
                    'Accumulator1DataType','CustomAccumulator1DataType',...
                    'ProductInputDataType','CustomProductInputDataType',...
                    'ProductOutputDataType','CustomProductOutputDataType',...
                    'Accumulator2DataType','CustomAccumulator2DataType',...
                    'Accumulator3DataType','CustomAccumulator3DataType',...
                    'NoiseScalingInputDataType','CustomNoiseScalingInputDataType',...
                    'InverseVarianceDataType','CustomInverseVarianceDataType',...
                    'OutputDataType','CustomOutputDataType'}];
                else






                    props={'FullPrecisionOverride'};


                    if strcmp(obj.VarianceSource,'Input port')
                        props{end+1}='Variance';
                        props{end+1}='InverseVarianceDataType';
                        props{end+1}='CustomInverseVarianceDataType';
                    elseif~matlab.system.isSpecifiedTypeMode(obj.InverseVarianceDataType)
                        props{end+1}='CustomInverseVarianceDataType';
                    end

                    if~matlab.system.isSpecifiedTypeMode(obj.ConstellationDataType)
                        props{end+1}='CustomConstellationDataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.Accumulator1DataType)
                        props{end+1}='CustomAccumulator1DataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.ProductInputDataType)
                        props{end+1}='CustomProductInputDataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.ProductOutputDataType)
                        props{end+1}='CustomProductOutputDataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.Accumulator2DataType)
                        props{end+1}='CustomAccumulator2DataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.Accumulator3DataType)
                        props{end+1}='CustomAccumulator3DataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.NoiseScalingInputDataType)
                        props{end+1}='CustomNoiseScalingInputDataType';
                    end
                    if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                        props{end+1}='CustomOutputDataType';
                    end
                end
            end





            if isequal(obj.OutputDataType,'Custom')&&~(...
                isequal(obj.DecisionMethod,'Log-likelihood ratio')&&...
                obj.BitOutput)
                idx=strcmp('CustomOutputDataType',props);
                props(idx)=[];
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)





            if(obj.BitOutput&&strcmp(obj.DecisionMethod,'Log-likelihood ratio'))...
                ||(strcmp(obj.OutputDataType,'Full precision')&&isInputFloatingPoint(obj,1))
                setPortDataTypeConnection(obj,1,1);
            end

        end
    end

    methods(Access=private)
        function out=isFxPtOutputDataType(obj)
            out=false;
            if obj.BitOutput&&...
                strcmp(obj.DecisionMethod,'Approximate log-likelihood ratio')
                out=true;
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.GeneralQAMDemodulator',...
            comm.GeneralQAMDemodulator.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndam3/General QAM Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Constellation',...
            'BitOutput',...
            'DecisionMethod',...
            'VarianceSource',...
            'Variance',...
            'OutputDataType',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride',...
            'RoundingMethod','OverflowAction',...
            'ConstellationDataType','CustomConstellationDataType',...
            'Accumulator1DataType','CustomAccumulator1DataType',...
            'ProductInputDataType','CustomProductInputDataType',...
            'ProductOutputDataType','CustomProductOutputDataType',...
            'Accumulator2DataType','CustomAccumulator2DataType',...
            'Accumulator3DataType','CustomAccumulator3DataType',...
            'NoiseScalingInputDataType','CustomNoiseScalingInputDataType',...
            'InverseVarianceDataType','CustomInverseVarianceDataType',...
            'CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'Constellation'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
    methods(Access=protected)
        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.system.SFunSystem(obj,s,wasLocked);
            obj.BitOutput=s.BitOutput;
        end
    end
end



