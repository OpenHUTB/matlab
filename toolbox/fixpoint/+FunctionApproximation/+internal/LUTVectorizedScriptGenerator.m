classdef LUTVectorizedScriptGenerator<FunctionApproximation.internal.LUTScriptFactory



    properties
        InterpMethod;
        LUTData;
        BreakpointValues;
        DataTypes;
        Spacing;
    end

    methods
        function this=LUTVectorizedScriptGenerator(tableData,inputType,outputType,spacing)
            this.InterpMethod=tableData.Interpolation;
            this.Spacing=double(spacing);
            this.LUTData=tableData.TableValues;
            this.BreakpointValues=tableData.BreakpointValues;
            this.DataTypes=FunctionApproximation.internal.Utils.getDataTypesForLUTScript(tableData,inputType,outputType);
        end

        function codeString=getMATLABScript(this)
            codeString=FunctionApproximation.internal.getVectorizedTemplateString(this.InterpMethod,this.Spacing);

            castInputString=getCastInputString(this);
            codeString=strrep(codeString,'#CAST_INPUT_VALUE',castInputString);

            [inputArgsString,inputArgs1String]=getInputArgsString(this);
            codeString=strrep(codeString,'#INPUT_ARGS',inputArgsString);
            codeString=strrep(codeString,'#INPUT_ARG1',inputArgs1String);

            indexTypeString=getIndexTypeString(this);
            codeString=strrep(codeString,'#INDEX_TYPE',indexTypeString);

            indexSearchString=getIndexSearchString(this);
            codeString=strrep(codeString,'#INDEX_SEARCH',indexSearchString);

            outputTypeStr=getStringsForOutputType(this);
            codeString=strrep(codeString,'#OUTPUT_TYPE',outputTypeStr);

            intermediateValueString=getStringToDefineIntermediateValue(this);
            codeString=strrep(codeString,'#INTERMEDIATE_VALUE',intermediateValueString);

            deltaValuesString=getStringToDefineDifferenceType(this);
            codeString=strrep(codeString,'#DIFFERENCE_VALUE',deltaValuesString);

            removeFimathStr=getStringToRemoveFimath(this);
            codeString=strrep(codeString,'#REMOVE_FIMATH',removeFimathStr);

            numeratorDefinitionString=getStringToDefineNumerator(this);
            codeString=strrep(codeString,'#DEFINE_NUMERATOR',numeratorDefinitionString);

            denominatorDefinitionString=getStringToDefineDenominator(this);
            codeString=strrep(codeString,'#DEFINE_DENOMINATOR',denominatorDefinitionString);

            [fracTypeStr,fractionStr]=getFractionStrings(this);
            codeString=strrep(codeString,'#FRACTION_TYPE',fracTypeStr);
            codeString=strrep(codeString,'#FRACTION_CALCULATION',fractionStr);

            tableValuesString=getTableValuesString(this);
            codeString=strrep(codeString,'#TABLE_VALUES',tableValuesString);

            breakpointValuesString=getBreakpointValuesString(this);
            codeString=strrep(codeString,'#BREAKPOINT_VALUES',breakpointValuesString);

            interpLogicStr=getStringsForInterpolation(this);
            codeString=strrep(codeString,'#OUTPUT_LOGIC',interpLogicStr);

            strideString=getStringToDefineStride(this);
            codeString=strrep(codeString,'#STRIDE',strideString);

            prelookupString=getprelookupString(this);
            codeString=strrep(codeString,'#PRELOOKUP',prelookupString);

            codeString=getCommentstoAddString(this,codeString);
        end

        function castInputString=getCastInputString(this)
            castInputString=FunctionApproximation.internal.getStringToCastInputValue(this.DataTypes.InputType,this.DataTypes.BreakpointType);
        end

        function[inputArgsString,inputArgs1String]=getInputArgsString(this)
            [inputArgsString,inputArgs1String]=FunctionApproximation.internal.getInputArgsString(numel(this.DataTypes.InputType));
        end

        function indexTypeString=getIndexTypeString(~)
            indexTypeString=FunctionApproximation.internal.getIndexTypeString();
        end

        function indexSearchString=getIndexSearchString(this)
            indexSearchString=FunctionApproximation.internal.getVectorizedIndexSearchString(this.Spacing,this.DataTypes.InputType);
        end

        function outputTypeStr=getStringsForOutputType(this)
            outputTypeStr=FunctionApproximation.internal.getStringForOutputType(this.DataTypes.OutputType);
        end

        function intermediateValueString=getStringToDefineIntermediateValue(this)
            intermediateValueString=FunctionApproximation.internal.getStringToDefineIntermediateValue(this.DataTypes.IntermediateType);
        end

        function deltaValueString=getStringToDefineDifferenceType(this)
            deltaValueString=FunctionApproximation.internal.getStringToDefineDifferenceType(this.DataTypes.DifferenceType);
        end

        function removeFimathStr=getStringToRemoveFimath(this)
            removeFimathStr=FunctionApproximation.internal.getStringToRemoveFimath(this.DataTypes.OutputType);
        end

        function numeratorDefinitionString=getStringToDefineNumerator(this)
            numeratorDefinitionString=FunctionApproximation.internal.getStringToDefineNumerator(this.DataTypes.NumeratorType);
        end

        function denominatorDefinitionString=getStringToDefineDenominator(this)
            denominatorDefinitionString=FunctionApproximation.internal.getStringToDefineDenominatorReciprocal(this.DataTypes.DenominatorReciprocalType);
        end

        function[fracTypeStr,fractionStr]=getFractionStrings(this)
            [fracTypeStr,fractionStr]=FunctionApproximation.internal.getFractionStrings(this.DataTypes.FractionType);
        end

        function tableValuesString=getTableValuesString(this)
            strategyContext=getTableValuesContext(this);
            strategy=FunctionApproximation.internal.tablevaluesstrategy.TableValuesStrategyFactory.getStrategy(this.InterpMethod);
            tableValuesString=strategy.getString(strategyContext);
        end

        function breakpointValuesString=getBreakpointValuesString(this)
            strategyContext=getBreakpointValuesContext(this);
            strategy=FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointValuesStrategyFactory.getStrategy(this.InterpMethod);
            breakpointValuesString=strategy.getString(strategyContext);
        end

        function interpLogicStr=getStringsForInterpolation(this)
            context=getInterpolationStrategyContext(this);
            strategy=FunctionApproximation.internal.vectorizedinterpolation.VectorizedInterpolationStrategyFactory.getInterpolationStrategy(this.InterpMethod);
            interpLogicStr=strategy.getInterpolationLogicString(context);
        end

        function strideString=getStringToDefineStride(this)
            strideString=FunctionApproximation.internal.getStringToDefineStride(this.BreakpointValues);
        end

        function prelookupString=getprelookupString(this)
            strategy=FunctionApproximation.internal.vectorizedprelookupfunction.VectorizedPrelookupStrategyFactory.getPrelookupStrategy(this.InterpMethod);
            prelookupString=strategy.getPrelookupString(this.Spacing,numel(this.BreakpointValues));
        end

        function context=getTableValuesContext(this)
            context=FunctionApproximation.internal.tablevaluesstrategy.TableValuesStrategyContext;
            context.TableValues=this.LUTData;
            context.TableValuesType=this.DataTypes.TableValuesType;
            context.OutputType=this.DataTypes.OutputType;
        end

        function context=getBreakpointValuesContext(this)
            context=FunctionApproximation.internal.breakpointvaluesstrategy.BreakpointValuesStrategyContext;
            context.BreakpointValues=this.BreakpointValues;
            context.BreakpointValuesType=this.DataTypes.BreakpointType;
            context.InputType=this.DataTypes.InputType;
            context.Spacing=this.Spacing;
        end

        function context=getInterpolationStrategyContext(this)
            context=FunctionApproximation.internal.vectorizedinterpolation.VectorizedInterpolationStrategyContext;
            context.OutputType=this.DataTypes.OutputType;
            context.TableValuesType=this.DataTypes.TableValuesType;
            context.NumberOfInputs=numel(this.DataTypes.InputType);
        end

        function codeString=getCommentstoAddString(~,codeString,~,~)
            codeString=strrep(codeString,'#HEADER_COMMENT','');
            codeString=strrep(codeString,'#PROBLEM_DEFINITION_COMMENT','');
        end
    end
end


