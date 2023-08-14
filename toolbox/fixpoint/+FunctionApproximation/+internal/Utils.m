classdef(Sealed)Utils<FunctionApproximation.internal.AbstractUtils





    methods(Static)
        function licenseCheck()
            fpdLicenseCheck();
        end

        function isOpen=isAnyModelOpen()











            validator=FunctionApproximation.internal.utilities.ModelOpenValidator();
            isOpen=validate(validator);
        end

        function isValid=isDataTypeStringValid(dataTypeString,context)














            if nargin<2
                context=[];
            end
            dataTypeContainer=FunctionApproximation.internal.Utils.dataTypeParser(dataTypeString,context);
            isValid=isFixed(dataTypeContainer)||isFloat(dataTypeContainer)||isBoolean(dataTypeContainer);
        end

        function isValid=isAbsoluteToleranceAchievable(dataType,absoluteTolerance)


















            if~(isnumerictype(dataType)||isa(dataType,'Simulink.NumericType'))
                error(message('SimulinkFixedPoint:functionApproximation:typeMustBeNumerictype'))
            end
            toleranceCalculator=FunctionApproximation.internal.utilities.MinimumToleranceCalculator();
            validator=FunctionApproximation.internal.utilities.AbsoluteToleranceValidator();
            isValid=validate(validator,dataType,absoluteTolerance,toleranceCalculator);
        end

        function minimumAbsoluteTolerance=getMinimumAbsoluteTolerance(dataType)















            if~(isnumerictype(dataType)||isa(dataType,'Simulink.NumericType'))
                error(message('SimulinkFixedPoint:functionApproximation:typeMustBeNumerictype'))
            end
            toleranceCalculator=FunctionApproximation.internal.utilities.MinimumToleranceCalculator();
            minimumAbsoluteTolerance=getTolerance(toleranceCalculator,dataType);
        end

        function dataTypeContainerInfo=dataTypeParser(dataTypeString,context)







            if nargin<2
                context=[];
            end
            dataTypeContainerInfo=parseDataType(dataTypeString,context);
        end

        function isRepresentable=isPerfectlyRepresentable(value,numerictype)












            validator=FunctionApproximation.internal.utilities.QuantizedEqualsOriginalValidator();
            isRepresentable=validate(validator,value,numerictype);
        end

        function[isValid,diagnostic]=isBlockPathValid(blockPath)






            validator=FunctionApproximation.internal.utilities.BlockPathValidator();
            isValid=validate(validator,blockPath);
            diagnostic=validator.Diagnostic;
        end

        function blockType=getBlockType(blockPath)








            blockType=FunctionApproximation.internal.BlockType.getEnum(blockPath);
        end

        function inRange=areValuesInRepresentableRange(values,dataType)











            values=FunctionApproximation.internal.Utils.parseCharValue(values);
            if(ischar(dataType)||isstring(dataType))
                dataTypeContainer=FunctionApproximation.internal.Utils.dataTypeParser(dataType);
                dataType=dataTypeContainer.ResolvedType;
            end
            validator=FunctionApproximation.internal.utilities.InRangeValidator();
            inRange=validate(validator,values,dataType);
        end

        function isValid=isWordLengthValid(wordLengthVector,modelName)













            validator=FunctionApproximation.internal.utilities.WordLengthValidator();
            isValid=validate(validator,wordLengthVector,modelName);
        end

        function[isValid,diagnostic]=isLUTBlock(blockPath)



            validator=FunctionApproximation.internal.utilities.LUTBlockTypeValidator();
            isValid=validate(validator,blockPath);
            diagnostic=validator.Diagnostic;
        end

        function[isValid,diagnostic]=isSubSystem(blockPath,options)



            if nargin<2
                options=FunctionApproximation.Options('LicenseCheck',false);
            end

            validator=FunctionApproximation.internal.utilities.SubSystemValidator();
            isValid=validate(validator,blockPath,options);
            diagnostic=validator.Diagnostic;
        end

        function[isValid,diagnostic]=isMathFunctionBlock(blockPath)





            validator=FunctionApproximation.internal.utilities.MathFunctionBlockTypeValidator();
            isValid=validate(validator,blockPath);
            diagnostic=validator.Diagnostic;
        end

        function currentBlockPath=getCurrentBlockPath(blockTypeEnum)











            if nargin==0
                blockTypeEnum=FunctionApproximation.internal.BlockType.GenericBlock;
            end
            blockPathRetriever=FunctionApproximation.internal.utilities.CurrentBlockPathRetriever();
            currentBlockPath=blockPathRetriever.retrieve(blockTypeEnum);
            if~isempty(currentBlockPath)
                blockPath=Simulink.BlockPath(currentBlockPath);
                currentBlockPath=blockPath.getBlock(1);
            end
        end

        function[success,diagnostic]=isBlockValidInputFunction(functionToApproximate,options)



            if nargin<2
                options=FunctionApproximation.Options();
            end

            success=false;
            diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:blockTypeNotSupported'));

            blockType=FunctionApproximation.internal.Utils.getBlockType(functionToApproximate);
            if blockType=="BlockDiagram"
                success=false;
            elseif FunctionApproximation.internal.Utils.isEncapsulatedBlock(functionToApproximate)
                functionToApproximate=get_param(functionToApproximate,'Parent');
                [success,diagnostic]=FunctionApproximation.internal.Utils.isSubSystem(functionToApproximate,options);
            elseif FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(functionToApproximate)
                success=true;
                diagnostic=MException.empty();
            elseif blockType=="Math"
                [success,diagnostic]=FunctionApproximation.internal.Utils.isMathFunctionBlock(functionToApproximate);
            elseif blockType=="LUT"
                [success,diagnostic]=FunctionApproximation.internal.Utils.isLUTBlock(functionToApproximate);
            elseif blockType=="SubSystem"
                [success,diagnostic]=FunctionApproximation.internal.Utils.isSubSystem(functionToApproximate,options);
            end
        end

        function[success,diagnostic]=isFunctionHandleValidInputFunction(functionHandle)
            validator=FunctionApproximation.internal.utilities.SpecialFunctionHandleValidator();
            success=validate(validator,functionHandle);

            if~success
                validator=FunctionApproximation.internal.utilities.GenericFunctionHandleValidator();
                success=validate(validator,functionHandle);
            end

            if~success
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidFunctionToApproximate'));
            else
                diagnostic=MException.empty;
            end
        end

        function[success,diagnostic,modifiedFunction]=validateFunctionToApproximate(functionToApproximate,options)




...
...
...
...
...
...
...

            if nargin<2
                options=FunctionApproximation.Options('LicenseCheck',false);
            end

            success=false;
            diagnostic=MException.empty();



            functionToApproximate=FunctionApproximation.internal.Utils.updateCurveFitWSVariable(functionToApproximate);

            modifiedFunction=functionToApproximate;
            if ischar(functionToApproximate)||isstring(functionToApproximate)
                if strcmp(functionToApproximate,FunctionApproximation.internal.functionsignatures.getExampleString)
                    success=true;
                    modifiedFunction=FunctionApproximation.internal.functionsignatures.getExampleString();
                elseif ismember(functionToApproximate,FunctionApproximation.internal.ProblemDefinitionFactory.getMathFunctionStrings())
                    functionHandle=FunctionApproximation.internal.ProblemDefinitionFactory.getMathFunctionHandle(functionToApproximate);
                    [success,diagnostic]=FunctionApproximation.internal.Utils.isFunctionHandleValidInputFunction(functionHandle);
                    modifiedFunction=functionHandle;
                elseif exist(functionToApproximate,'builtin')
                    functionHandle=str2func(functionToApproximate);
                    try
                        [success,diagnostic]=FunctionApproximation.internal.Utils.isFunctionHandleValidInputFunction(functionHandle);
                        modifiedFunction=functionHandle;
                    catch
                        success=false;
                        diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidFunctionToApproximate'));
                    end
                elseif FunctionApproximation.internal.Utils.isBlockPathValid(functionToApproximate)
                    [success,diagnostic]=FunctionApproximation.internal.Utils.isBlockValidInputFunction(functionToApproximate,options);
                    isUnderApproximationBlock=FunctionApproximation.internal.approximationblock.isUnderFunctionApproximationBlock(functionToApproximate);
                    if isUnderApproximationBlock
                        modifiedFunction=FunctionApproximation.internal.approximationblock.getParentApproximationBlock(functionToApproximate);
                    end
                else
                    diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidFunctionToApproximate'));
                end
            elseif isa(functionToApproximate,'function_handle')
                [success,diagnostic]=FunctionApproximation.internal.Utils.isFunctionHandleValidInputFunction(functionToApproximate);
            elseif isa(functionToApproximate,'cfit')
                [success,diagnostic]=FunctionApproximation.internal.Utils.isCurveFitValidLibraryFunction(functionToApproximate);
                modifiedFunction=functionToApproximate;
            else
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidFunctionToApproximate'));
            end
        end

        function[success,diagnostic]=isFunctionVectorized(functionWrapper,inputLowerBounds,inputUpperBounds,embeddedNumerictypes)




            validator=FunctionApproximation.internal.utilities.VectorizedFunctionValidator();
            success=validate(validator,functionWrapper,inputLowerBounds,inputUpperBounds,embeddedNumerictypes);
            diagnostic=validator.Diagnostic;
        end

        function[success,diagnostic]=isFunctionElementWiseOperation(functionWrapper,inputLowerBounds,inputUpperBounds,embeddedNumerictypes)





            validator=FunctionApproximation.internal.utilities.ElementWiseOperationValidator();
            success=validate(validator,functionWrapper,inputLowerBounds,inputUpperBounds,embeddedNumerictypes);
            diagnostic=validator.Diagnostic;
        end

        function[success,diagnostic]=isFunctionTimeVariant(functionWrapper,inputLowerBounds,inputUpperBounds)





            validator=FunctionApproximation.internal.utilities.TimeVarianceValidator();
            success=validate(validator,functionWrapper,inputLowerBounds,inputUpperBounds);
            diagnostic=validator.Diagnostic;
        end

        function data=getLUTDataForFunctionToApproximate(problemDefinition)




            dataExtractor=FunctionApproximation.internal.utilities.LUTDataExtractor();
            data=dataExtractor.extractData(problemDefinition.InputFunctionWrapper);
        end

        function data=getLUTDataForApproximateFunction(solutionObject)




            dataExtractor=FunctionApproximation.internal.utilities.LUTDataExtractor();
            data=dataExtractor.extractData(solutionObject.ErrorFunction.Approximation);
        end

        function success=canDataTypeMeetTolerance(dataTypeForTolCheck,toleranceValue)



            success=FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(dataTypeForTolCheck)<=toleranceValue;
        end

        function[success,diagnostic]=replaceBlockWithBlock(originalBlockPath,substituteBlockPath)

            replacer=FunctionApproximation.internal.utilities.ReplaceBlockWithBlock();
            [success,diagnostic]=replacer.replace(originalBlockPath,substituteBlockPath);
        end

        function[success,diagnostic]=replaceBlockWithLUTSolution(originalBlockPath,solutionObject)


            replacer=FunctionApproximation.internal.utilities.ReplaceBlockWithLUTSolution();
            [success,diagnostic]=replacer.replace(originalBlockPath,solutionObject);
        end

        function[success,diagnostic]=checkIfNumberOfInterfacesMatch(originalBlockPath,substituteBlockPath)


            validator=FunctionApproximation.internal.utilities.BlockInterfaceCompatibilityValidator();
            success=validate(validator,originalBlockPath,substituteBlockPath);
            diagnostic=validator.Diagnostic;
        end

        function states=getInitialStates(blockPath)


            if~FunctionApproximation.internal.Utils.isBlockPathValid(blockPath)
                error(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
            end
            utility=FunctionApproximation.internal.utilities.SimulinkStatesExtractor();
            states=utility.extract(blockPath);
        end

        function[success,diagnostic]=isEncapsulatingSubSystem(blockPath)



            validator=FunctionApproximation.internal.utilities.EncapsulatingSubSystemValidator();
            success=validate(validator,blockPath);
            diagnostic=validator.Diagnostic;
        end

        function[success,diagnostic]=isEncapsulatedBlock(blockPath)



            validator=FunctionApproximation.internal.utilities.EncapsulatedBlockValidator();
            success=validate(validator,blockPath);
            diagnostic=validator.Diagnostic;
        end

        function parsedValue=parseCharValue(value)














            utility=FunctionApproximation.internal.utilities.CharValueParser();
            parsedValue=utility.parse(value);
        end

        function[success,diagnostic]=isBlockInterfaceValid(blockPath)



            validator=FunctionApproximation.internal.utilities.BlockInterfaceValidator();
            success=validate(validator,blockPath);
            diagnostic=validator.Diagnostic;
        end

        function[success,diagnostic]=isProblemAUTOSARCompliant(problemDefintion)













            validator=FunctionApproximation.internal.utilities.ProblemAUTOSARComplianceValidator();
            success=validate(validator,problemDefintion);
            diagnostic=validator.Diagnostic;
        end

        function[success,diagnostic]=isLUTDBunitAUTOSARCompliant(lutDBUnit,interfaceTypes)







            if nargin==2
                lutDBUnit.SerializeableData.InputTypes=interfaceTypes(1:end-1);
                lutDBUnit.SerializeableData.OutputType=interfaceTypes(end);
            end

            validator=FunctionApproximation.internal.utilities.LUTDBUnitAUTOSARComplianceValidator();
            success=validate(validator,lutDBUnit);
            diagnostic=validator.Diagnostic;
        end

        function[success,diagnostic]=isAUTOSARBlocksetLicenseAvailable(options)









            success=true;
            if options.AUTOSARCompliant
                success=license('test','autosar_blockset')&&options.ConsiderAUTOSARBlocksetExists;
            end

            if success
                diagnostic=MException.empty();
            else
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:failedToCheckoutAUTOSARBlocksetLicense'));
            end
        end

        function structFromProblem=getStructFromProblem(problemDefinition)








            converter=FunctionApproximation.internal.utilities.ProblemToStructConverter();
            structFromProblem=convert(converter,problemDefinition);
        end

        function structFromOptions=getStructFromOptions(options)







            converter=FunctionApproximation.internal.utilities.OptionsToStructConverter();
            structFromOptions=convert(converter,options);
        end

        function compactString=getCompactStringForIntegerVector(values)
















            converter=FunctionApproximation.internal.utilities.IntegerVectorToStringConverter();
            compactString=convert(converter,values);
        end

        function[success,diagnostic]=convertStringToFile(string,fileName)


            converter=FunctionApproximation.internal.utilities.StringToFileConverter();
            [success,diagnostic]=converter.convertToFile(string,fileName);
        end

        function[success,diagnostic]=isProblemValidForHDLOptimizedMode(problemDefintion)






            validator=FunctionApproximation.internal.utilities.ProblemHDLOptimizedModeValidator();
            success=validate(validator,problemDefintion);
            diagnostic=validator.Diagnostic;
        end

        function[success,diagnostic]=isProblemValidForMATLAB(problemDefintion)
            validator=FunctionApproximation.internal.utilities.ProblemForMATLABLUTValidator();
            success=validate(validator,problemDefintion);
            diagnostic=validator.Diagnostic;
        end

        function dataTypes=getDataTypesForLUTScript(tableData,inputType,outputType)
























            dataTypes=FunctionApproximation.internal.utilities.DataTypesForLUTScript(tableData,inputType,outputType);
        end

        function coordinates=getCoordinates(linearIndices,tableSize,grid)























            extractor=FunctionApproximation.internal.utilities.CoordinateExtrator();
            coordinates=extractor.extract(linearIndices,tableSize,grid);
        end

        function updatedFunction=updateCurveFitWSVariable(functionToApproximate)


            updatedFunction=functionToApproximate;
            [isCurveFitVariable,curveFitObject]=FunctionApproximation.internal.utilities.CurveFitVariableFromWorkspace.getCurveFitVarFromBase(functionToApproximate);

            if isCurveFitVariable
                updatedFunction=curveFitObject;
            end
        end

        function[success,diagnostic]=validateClassregDataTypeStruct(dtStruct)

            success=true;
            diagnostic=MException.empty();
            if~isstruct(dtStruct)&&...
                (~isfield(dtStruct,'XDataType')&&~isfield(dtStruct,'TransformedScoreDataType')&&~isfield(dtStruct,'YFitDataType'))
                success=false;
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidDataTypeStructClassreg'));
            end
        end

        function[success,diagnostic,loadedFile]=validateClassregMatFile(filename)
            success=true;
            diagnostic=MException.empty();
            try



                loadedFile=load(filename);
                if~isfield(loadedFile,'compactStruct')


                    success=false;
                end
            catch err %#ok<NASGU>
                loadedFile=[];
                success=false;
            end

            if~success
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidMatFileClassreg'));
            end
        end

        function[success,diagnostic]=isCurveFitValidLibraryFunction(functionToApproximate)


            if isempty(functionToApproximate)
                success=false;
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:cfitLibraryNotSupported'));
            else
                success=true;
                diagnostic=MException.empty;
            end
        end

        function flag=isFlat1DExplicitValueOffCurveUnsaturatedOutput(options,numberOfDimensions)







            flag=(numberOfDimensions==1)...
            &&(options.Interpolation=="Flat")...
            &&(options.BreakpointSpecification=="ExplicitValues")...
            &&(options.OnCurveTableValues==false)...
            &&(options.SaturateToOutputType==false);
        end

    end
end


