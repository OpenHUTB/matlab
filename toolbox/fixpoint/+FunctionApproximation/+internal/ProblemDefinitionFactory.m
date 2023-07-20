classdef ProblemDefinitionFactory





    properties(Constant)
        SpecialMathFunctionProblemDefinition=FunctionApproximation.internal.getSpecialMathFunctionData();
    end

    methods
        function[problemDefinition,options]=getProblemDefinition(this,functionToApproximate,options)
            problemDefinition=FunctionApproximation.internal.ProblemDefinition();
            problemDefinition.FunctionToApproximate=functionToApproximate;

            if ischar(functionToApproximate)
                if strcmp(functionToApproximate,FunctionApproximation.internal.functionsignatures.getExampleString())
                    [problemDefinition,options]=getProblemDefinitionForExampleProblem(this,problemDefinition,options);
                elseif FunctionApproximation.internal.Utils.isBlockPathValid(functionToApproximate)
                    [problemDefinition,options]=getProblemDefinitionForBlockPath(this,functionToApproximate,problemDefinition,options);
                end
            elseif isa(functionToApproximate,'function_handle')
                [problemDefinition,options]=getProblemDefinitionForFunctionHandle(this,functionToApproximate,problemDefinition,options);
            elseif isa(functionToApproximate,'cfit')
                [problemDefinition,options]=getProblemDefinitionForCurveFit(this,problemDefinition,options);
            end
        end

        function[problemDefinition,options]=getProblemDefinitionForLUTBlock(~,functionToApproximate,problemDefinition,options)
            modelCompiled=~strcmp(get_param(bdroot(functionToApproximate),'SimulationStatus'),'stopped');
            blockToDataAdapter=FunctionApproximation.internal.getLUTBlockToDataAdapter(options.AllowUpdateDiagram,modelCompiled);
            blockToDataAdapter=blockToDataAdapter.update(functionToApproximate);
            rangeObject=getRangeObject(blockToDataAdapter);
            problemDefinition.InputLowerBounds=rangeObject.Minimum;
            problemDefinition.InputUpperBounds=rangeObject.Maximum;
            problemDefinition.InputTypes=blockToDataAdapter.InputTypes;
            problemDefinition.OutputType=blockToDataAdapter.OutputType;
            problemDefinition.InputFunctionWrapper=FunctionApproximation.internal.getWrapper(blockToDataAdapter,options);
        end

        function[problemDefinition,options]=getProblemDefinitionForMathFunctionBlock(this,functionToApproximate,options)
            blockObject=get_param(functionToApproximate,'Object');
            mathFunction=this.mapBlockOperatorToMathFunction(blockObject);
            [problemDefinition,options]=getProblemDefinition(this,this.getMathFunctionHandle(mathFunction),options);
            problemDefinition.FunctionToApproximate=functionToApproximate;
            if options.AllowUpdateDiagram
                modelCompileHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(functionToApproximate);
                start(modelCompileHandler);

                blockInterfaceParser=FunctionApproximation.internal.BlockInterfaceParser;
                problemDefinition.InputTypes=getInputTypes(blockInterfaceParser,blockObject);
                problemDefinition.OutputType=getOutputTypes(blockInterfaceParser,blockObject);

                if~fixed.internal.type.isAnyFloat(problemDefinition.OutputType)
                    outputTypeRange=double(range(fi([],problemDefinition.OutputType)));
                    problemDefinition.InputFunctionWrapper=saturateWrapper(problemDefinition.InputFunctionWrapper,outputTypeRange(1),outputTypeRange(2));
                end

                stop(modelCompileHandler);
            end
        end

        function[problemDefinition,options]=getProblemDefinitionForSubSystem(this,functionToApproximate,problemDefinition,options)
            if FunctionApproximation.internal.Utils.isEncapsulatingSubSystem(functionToApproximate)
                [problemDefinition,options]=getProblemDefinitionForEncapsulatingSubSystem(this,functionToApproximate,problemDefinition,options);
            else
                blockToDataAdapter=FunctionApproximation.internal.getBlockToDataAdapter(options.AllowUpdateDiagram);
                if strcmp(get_param(functionToApproximate,'Variant'),'on')
                    functionToApproximate=get_param(functionToApproximate,'ActiveVariantBlock');
                end
                blockToDataAdapter=blockToDataAdapter.update(functionToApproximate);
                problemDefinition.InputTypes=blockToDataAdapter.InputTypes;
                for iDim=1:numel(problemDefinition.InputTypes)
                    problemDefinition.InputLowerBounds(iDim)=-Inf;
                    problemDefinition.InputUpperBounds(iDim)=Inf;
                    if~fixed.internal.type.isAnyFloat(problemDefinition.InputTypes(iDim))
                        r=range(fi([],problemDefinition.InputTypes(iDim)));
                        problemDefinition.InputLowerBounds(iDim)=r(1);
                        problemDefinition.InputUpperBounds(iDim)=r(2);
                    end
                end
                problemDefinition.OutputType=blockToDataAdapter.OutputType;
                problemDefinition.InputFunctionWrapper=FunctionApproximation.internal.getWrapper(blockToDataAdapter,options);
            end
            problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.SubSystem;
        end

        function[problemDefinition,options]=getProblemDefinitionForSpecialMathFunctions(this,functionToApproximate,problemDefinition,options)
            [~,location]=this.getMathFunctionString(functionToApproximate);
            if~isempty(location)
                data=this.SpecialMathFunctionProblemDefinition(location,:);
                fieldNamesForProblemDefinition=fieldnames(data{2});
                for iNames=1:numel(fieldNamesForProblemDefinition)
                    fieldName=fieldNamesForProblemDefinition{iNames};
                    problemDefinition.(fieldName)=data{2}.(fieldName);
                end

                fieldNamesForOptions=fieldnames(data{3});
                for iNames=1:numel(fieldNamesForOptions)
                    fieldName=fieldNamesForOptions{iNames};
                    options=this.setOptionsProperty(options,fieldName,data{3}.(fieldName));
                end
            end
        end

        function[problemDefinition,options]=getProblemDefinitionForExampleProblem(~,problemDefinition,options)
            problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.SpecialFunctionHandle;
            problemDefinition.FunctionToApproximate=@sin;
            problemDefinition.InputTypes=numerictype(0,16,13);
            problemDefinition.InputLowerBounds=0;
            problemDefinition.InputUpperBounds=pi/2;
            problemDefinition.OutputType=numerictype(1,16,14);
            options.BreakpointSpecification=FunctionApproximation.BreakpointSpecification.EvenSpacing;
            problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.SpecialFunctionHandle;
        end

        function[problemDefinition,options]=getProblemDefinitionForFunctionHandle(this,functionToApproximate,problemDefinition,options)
            if ismember(this.getMathFunctionString(functionToApproximate),this.getMathFunctionStrings())
                [problemDefinition,options]=getProblemDefinitionForSpecialMathFunctions(this,functionToApproximate,problemDefinition,options);
                problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.SpecialFunctionHandle;
            else
                problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.GenericFunctionHandle;
                options=this.setOptionsProperty(options,'UseClipping',true);
            end
            problemDefinition.InputFunctionWrapper=FunctionApproximation.internal.getWrapper(problemDefinition.FunctionToApproximate);
        end

        function[problemDefinition,options]=getProblemDefinitionForBlockPath(this,functionToApproximate,problemDefinition,options)


            functionToApproximate=Simulink.BlockPath(functionToApproximate).convertToCell{1};
            if FunctionApproximation.internal.Utils.isEncapsulatedBlock(functionToApproximate)
                eSub=get_param(functionToApproximate,'Parent');
                [problemDefinition,options]=getProblemDefinition(this,eSub,options);
                problemDefinition.FunctionToReplace=eSub;
            elseif FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(functionToApproximate)
                [problemDefinition,options]=getProblemDefinitionForFunctionApproximationBlock(this,functionToApproximate,problemDefinition,options);
            elseif FunctionApproximation.internal.Utils.isMathFunctionBlock(functionToApproximate)
                [problemDefinition,options]=getProblemDefinitionForMathFunctionBlock(this,functionToApproximate,options);
                problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.MathBlock;
                problemDefinition.FunctionToReplace=functionToApproximate;
            elseif FunctionApproximation.internal.Utils.isLUTBlock(functionToApproximate)
                [problemDefinition,options]=getProblemDefinitionForLUTBlock(this,functionToApproximate,problemDefinition,options);
                problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.LUTBlock;
                options=this.setOptionsProperty(options,'UseClipping',true);
                problemDefinition.FunctionToReplace=functionToApproximate;
            elseif FunctionApproximation.internal.Utils.isSubSystem(functionToApproximate)
                [problemDefinition,options]=getProblemDefinitionForSubSystem(this,functionToApproximate,problemDefinition,options);
                options=this.setOptionsProperty(options,'UseClipping',true);
                problemDefinition.FunctionToReplace=functionToApproximate;
            else
                problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.GenericBlock;
                problemDefinition.FunctionToReplace=functionToApproximate;
            end
        end

        function[problemDefinition,options]=getProblemDefinitionForEncapsulatingSubSystem(this,functionToApproximate,problemDefinition,options)
            blockToDataAdapter=FunctionApproximation.internal.getBlockToDataAdapter(options.AllowUpdateDiagram);
            blockToDataAdapter=blockToDataAdapter.update(functionToApproximate);

            newFunctionToApproximate=[functionToApproximate,'/',DataTypeWorkflow.Advisor.internal.ReplacementSetUp.SourceBlockName];
            isMathFunctionBlock=FunctionApproximation.internal.Utils.isMathFunctionBlock(newFunctionToApproximate);
            if isMathFunctionBlock
                blockObject=get_param(newFunctionToApproximate,'Object');
                mathFunction=this.mapBlockOperatorToMathFunction(blockObject);
                functionHandle=this.getMathFunctionHandle(mathFunction);
                problemDefinition.InputFunctionWrapper=FunctionApproximation.internal.getWrapper(functionHandle);
                problemDefinition.FunctionToApproximate=newFunctionToApproximate;
            else
                problemDefinition.InputFunctionWrapper=FunctionApproximation.internal.getWrapper(blockToDataAdapter,options);
            end

            problemDefinition.InputTypes=blockToDataAdapter.InputTypes;
            problemDefinition.OutputType=blockToDataAdapter.OutputType;
            for iDim=1:numel(problemDefinition.InputTypes)
                inputType=problemDefinition.InputTypes(iDim);
                if~fixed.internal.type.isAnyFloat(inputType)
                    problemDefinition.InputLowerBounds(iDim)=lowerbound(inputType);
                    problemDefinition.InputUpperBounds(iDim)=upperbound(inputType);
                else
                    problemDefinition.InputLowerBounds(iDim)=-Inf;
                    problemDefinition.InputUpperBounds(iDim)=Inf;
                end
            end
        end

        function[problemDefinition,options]=getProblemDefinitionForFunctionApproximationBlock(this,functionToApproximate,problemDefinition,options)
            schema=FunctionApproximation.internal.approximationblock.BlockSchema();
            approximationBlockInfo=FunctionApproximation.internal.approximationblock.getApproximationBlockInfoUsingBlock(functionToApproximate);
            problemStructParameter=approximationBlockInfo.MaskObject.getParameter(schema.ProblemStructParameterName);
            problemStruct=jsondecode(problemStructParameter.Value);
            functionType=FunctionApproximation.internal.FunctionType(problemStruct.InputFunctionType);
            if isBlock(functionType)
                resolvedFunction=schema.getOriginalSource(approximationBlockInfo.BlockPath);
                if functionType=="MathBlock"
                    blockObject=get_param(resolvedFunction,'Object');
                    mathFunction=this.mapBlockOperatorToMathFunction(blockObject);
                    [problemDefinition,options]=getProblemDefinition(this,this.getMathFunctionHandle(mathFunction),options);
                    problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.MathBlock;
                    problemDefinition.FunctionToReplace=functionToApproximate;
                else
                    problemDefinition.FunctionToReplace=functionToApproximate;
                    blockToDataAdapter=FunctionApproximation.internal.serializabledata.getAdapterForNoCompileUsingFunctionType(functionType);
                    problemDefinition.InputTypes=problemStruct.InputTypes;
                    problemDefinition.OutputType=problemStruct.OutputType;
                    blockToDataAdapter=blockToDataAdapter.update(resolvedFunction);
                    blockToDataAdapter.InputTypes=problemDefinition.InputTypes;
                    blockToDataAdapter.OutputType=problemDefinition.OutputType;
                    if~isempty(problemStruct.StorageTypes)
                        blockToDataAdapter.StorageTypes=FunctionApproximation.internal.ProblemDefinition.getNumericTypes(problemStruct.StorageTypes);
                    end
                    problemDefinition.InputFunctionWrapper=FunctionApproximation.internal.functionwrapper.BlockWrapper(blockToDataAdapter);
                    modelInfo=problemDefinition.InputFunctionWrapper.FunctionToEvaluate;
                    FunctionApproximation.internal.Utils.replaceBlockWithBlock(modelInfo.getBlockPath(),resolvedFunction);
                    modelWorkspace=modelInfo.ModelWorkspace;
                    dependentVariables=problemStruct.DependentVariables;
                    dependentVariables=convertCharsToStrings(dependentVariables);
                    for ii=1:numel(dependentVariables)
                        variableName=char(dependentVariables(ii));
                        try
                            variableValue=slResolve(variableName,problemDefinition.FunctionToReplace);
                            modelWorkspace.assignin(variableName,variableValue);
                        catch err %#ok<NASGU> % for debugging








                        end
                    end
                end
                problemDefinition.FunctionToApproximate=resolvedFunction;
            else
                resolvedFunction=FunctionApproximation.internal.Utils.parseCharValue(problemStruct.FunctionToApproximate);
                [problemDefinition,options]=getProblemDefinition(this,resolvedFunction,options);
                problemDefinition.FunctionToReplace=functionToApproximate;
            end
            problemDefinition.InputTypes=problemStruct.InputTypes;
            problemDefinition.OutputType=problemStruct.OutputType;
            problemDefinition.InputLowerBounds=problemStruct.InputLowerBounds;
            problemDefinition.InputUpperBounds=problemStruct.InputUpperBounds;
            problemDefinition.InputFunctionType=problemStruct.InputFunctionType;
            optionsStruct=problemStruct.Options;
            names=fieldnames(optionsStruct);
            for ii=1:numel(names)
                options=this.setOptionsProperty(options,names{ii},FunctionApproximation.internal.Utils.parseCharValue(optionsStruct.(names{ii})));
            end
        end

        function[problemDefinition,options]=getProblemDefinitionForCurveFit(this,problemDefinition,options)


            problemDefinition.InputFunctionType=FunctionApproximation.internal.FunctionType.GenericFunctionHandle;
            problemDefinition.InputFunctionWrapper=FunctionApproximation.internal.getWrapper(problemDefinition.FunctionToApproximate);
            options=this.setOptionsProperty(options,'UseClipping',true);
        end
    end

    methods(Static)
        function functionChoices=getMathFunctionStrings()


            functionChoices=FunctionApproximation.internal.ProblemDefinitionFactory.SpecialMathFunctionProblemDefinition(:,1);
        end

        function options=setOptionsProperty(options,fieldName,value)




            currentDefaultFields=options.DefaultFields;
            if ismember(fieldName,currentDefaultFields)
                options.(fieldName)=value;
                options.DefaultFields=currentDefaultFields;
            end
        end

        function[functionHandle,functionLocation]=getMathFunctionHandle(functionString)


            functionLocation=strcmp(FunctionApproximation.internal.ProblemDefinitionFactory.SpecialMathFunctionProblemDefinition(:,1),functionString);
            functionHandle=[];
            if any(functionLocation)
                functionHandle=FunctionApproximation.internal.ProblemDefinitionFactory.SpecialMathFunctionProblemDefinition{functionLocation,2}.FunctionToApproximate;
            end
        end

        function[functionString,functionLocation]=getMathFunctionString(functionHandle)




            allOptions=cellfun(@(x)func2str(x.FunctionToApproximate),...
            FunctionApproximation.internal.ProblemDefinitionFactory.SpecialMathFunctionProblemDefinition(:,2),'UniformOutput',false);
            functionLocation=strcmp(allOptions,func2str(functionHandle));
            if~any(functionLocation)
                handleGenerator=FunctionApproximation.internal.StandardFunctionHandleGenerator(functionHandle);
                functionLocation=strcmp(FunctionApproximation.internal.ProblemDefinitionFactory.SpecialMathFunctionProblemDefinition(:,1),extractFunctionName(handleGenerator));
            end

            if any(functionLocation)
                functionString=FunctionApproximation.internal.ProblemDefinitionFactory.SpecialMathFunctionProblemDefinition{functionLocation,1};
            else
                functionString='';
            end
        end

        function mappedFunction=mapBlockOperatorToMathFunction(blockObject)
            mathFunction=blockObject.Function;
            switch mathFunction
            case 'reciprocal'
                mappedFunction='1./x';
            case '10^u'
                mappedFunction='10.^x';
            case 'magnitude^2'
                mappedFunction='x.^2';
            case 'square'
                mappedFunction='x.^2';
            otherwise
                mappedFunction=mathFunction;
            end
        end

        function functionHandle=getFunctionHandleForSpecialFunction(functionHandle)


            specialFunctionsList=FunctionApproximation.internal.ProblemDefinitionFactory.getMathFunctionStrings();
            functionString=func2str(functionHandle);
            if ismember(functionString,specialFunctionsList)
                switch functionString
                case 'atan2'
                    functionHandle=@(x,y)atan2(x,y);
                otherwise
                    functionHandle=str2func(['@(x)',functionString,'(x)']);
                end
            end
        end
    end
end
