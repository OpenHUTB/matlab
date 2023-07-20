classdef DataTypesForLUTScript<handle











    properties
        TableValuesType;
        BreakpointType;
        InputType;
        OutputType;
        IntermediateType;
        FractionType=numerictype(0,32,31);
        IndexType;
        NumeratorType;
        DenominatorReciprocalType;
        DifferenceType;
    end

    methods
        function this=DataTypesForLUTScript(tableData,inputType,outputType)


            spacing=generateSpacingSpecification(this,tableData);
            this.TableValuesType=generateTableValuesType(this,tableData.TableDataType);
            this.BreakpointType=generateBreakpointType(this,tableData.BreakpointDataTypes);
            this.OutputType=generateOutputValueType(this,outputType);
            this.InputType=generateInputType(this,inputType);
            this.IndexType=generateIndexType(this);
            this.FractionType=generateFractionType(this,spacing);
            this.IntermediateType=generateIntermediateType(this,spacing);
            this.NumeratorType=generateNumeratorType(this,tableData.BreakpointValues);
            this.DenominatorReciprocalType=generateDenominatorReciprocalType(this,tableData.BreakpointValues);
            this.DifferenceType=generateDifferenceType(this,tableData.TableValues);
        end

        function tableValuesType=generateTableValuesType(~,type)
            tableValuesType=type;
        end

        function breakpointType=generateBreakpointType(~,type)
            breakpointType=type;
        end

        function outputValueType=generateOutputValueType(~,outputType)
            outputValueType=outputType;
        end

        function inputType=generateInputType(~,type)
            for i=1:numel(type)
                if type(i).ishalf
                    type(i)=numerictype('single');
                end
            end
            inputType=type;
        end

        function indexType=generateIndexType(~)
            indexType=uint32([]);
        end

        function fractionFiObj=generateFractionType(this,spacing)


            for i=1:numel(this.InputType)
                if isfloat(this.InputType(i))||isfloat(this.OutputType)||isfloat(this.TableValuesType)
                    fractionFiObj=FunctionApproximation.internal.utilities.GenerateDataTypeForFloatingPointRules.generateDataType([this.InputType(i),this.OutputType,this.TableValuesType]);

                    return;
                end











                overCoatType=fixed.internal.type.aggregateTypeMatchedSlopeBias(this.TableValuesType,this.OutputType);

                fractionWL=overCoatType.WordLength;
                fractionFL=fractionWL-1;





                fractionFiObj=fi([],numerictype(0,fractionWL,fractionFL));
                if this.TableValuesType.isscalingslopebias













                    productWL=fractionWL+this.TableValuesType.WordLength;
                    productFL=this.TableValuesType.FractionLength;

                    fractionFiObj.ProductMode='SpecifyPrecision';
                    fractionFiObj.ProductWordLength=productWL;
                    fractionFiObj.ProductFractionLength=productFL;




                    sumWL=productWL;
                    sumFL=productFL;

                    fractionFiObj.SumMode="SpecifyPrecision";
                    fractionFiObj.SumWordLength=sumWL;
                    fractionFiObj.SumFractionLength=sumFL;
                    if spacing==FunctionApproximation.BreakpointSpecification.EvenPow2Spacing
                        fractionFiObj.RoundingMethod='Floor';
                    end
                end
            end
        end

        function intermediateFiObj=generateIntermediateType(this,spacing)


            for i=1:numel(this.InputType)
                if isfloat(this.InputType(i))||isfloat(this.OutputType)||isfloat(this.TableValuesType)
                    intermediateFiObj=FunctionApproximation.internal.utilities.GenerateDataTypeForFloatingPointRules.generateDataType([this.InputType(i),this.OutputType,this.TableValuesType]);
                    return;
                end
                if isscalingslopebias(this.TableValuesType)


                    intermediateFiObj=fi([],this.OutputType);






                    intermediateFiObj.fimath=this.FractionType.fimath;

                    if spacing==FunctionApproximation.BreakpointSpecification.EvenPow2Spacing
                        intermediateFiObj.RoundingMethod='Floor';
                    end
                else

                    intermediateFiObj=...
                    FunctionApproximation.internal.utilities.IntermediateBinPtForLUTScript.getIntermediateBinPtForLUTScript(...
                    numel(this.InputType),...
                    this.OutputType,...
                    this.TableValuesType);
                end
            end
        end

        function numeratorType=generateNumeratorType(this,breakpointValues)


            for i=1:numel(this.InputType)
                for j=1:numel(this.BreakpointType)
                    if isfloat(this.InputType(i))||isfloat(this.BreakpointType(j))
                        numeratorType=FunctionApproximation.internal.utilities.GenerateDataTypeForFloatingPointRules.generateDataType([this.InputType(i),this.BreakpointType(j)]);
                        return;
                    end




                    if iscell(breakpointValues)
                        bpValues=[breakpointValues{:}];
                    else
                        bpValues=breakpointValues;
                    end
                    numeratorType=FunctionApproximation.internal.utilities.GenerateSuperSetDataType.generateDataType(this.InputType(i),this.BreakpointType(j),bpValues);
                end
            end
        end

        function denominatorReciprocalFiObj=generateDenominatorReciprocalType(this,breakpointValues)


            for i=1:numel(this.InputType)
                for j=1:numel(this.BreakpointType)
                    if isfloat(this.InputType(i))||isfloat(this.BreakpointType(j))
                        denominatorReciprocalFiObj=FunctionApproximation.internal.utilities.GenerateDataTypeForFloatingPointRules.generateDataType([this.InputType(i),this.BreakpointType(j)]);
                        return;
                    end




                    if iscell(breakpointValues)
                        bpValues=[breakpointValues{:}];
                    else
                        bpValues=breakpointValues;
                    end

                    denominatorReciprocalFiObj=fixed.internal.type.tightFixedPointType(1./diff(bpValues),max(32,this.BreakpointType(j).WordLength));
                    if this.BreakpointType(j).isscalingslopebias
                        denominatorReciprocalFiObj=fi(0,denominatorReciprocalFiObj);
                        denominatorReciprocalFiObj.fimath=this.NumeratorType.fimath;
                    end
                end
            end
        end

        function differenceFiObj=generateDifferenceType(this,tableValues)



            if this.IntermediateType.isscalingslopebias
                differenceFiObj=fi([],this.TableValuesType.Signed,this.TableValuesType.WordLength,this.TableValuesType.Slope,0);

                if all(min(tableValues)<=min(range(differenceFiObj)))||all(max(tableValues)>=max(range(differenceFiObj)))



                    differenceFiObj=fi([],this.TableValuesType.Signed,this.TableValuesType.WordLength,this.TableValuesType.Slope,this.TableValuesType.Bias);
                end
                differenceFiObj.fimath=this.IntermediateType.fimath;
            elseif this.IntermediateType.isscalingbinarypoint
                differenceFiObj=fi([],this.TableValuesType.Signed,this.TableValuesType.WordLength+1,this.TableValuesType.FractionLength);
            else
                differenceFiObj=fi([],this.IntermediateType);
            end
        end

        function spacing=generateSpacingSpecification(~,tableData)
            if tableData.IsEvenSpacing
                delta=diff(tableData.BreakpointValues{1});
                if all(mod(log2(delta),2)==0)
                    spacing=FunctionApproximation.BreakpointSpecification.EvenPow2Spacing;
                else
                    spacing=FunctionApproximation.BreakpointSpecification.EvenSpacing;
                end
            else
                spacing=FunctionApproximation.BreakpointSpecification.ExplicitValues;
            end
        end
    end
end



