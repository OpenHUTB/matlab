classdef Problem<FunctionApproximation.internal.ProblemDefinition







    properties(Hidden)
IsGridExhaustive
SampledTableData
SamplingGrid
        TemporaryModelHandler FunctionApproximation.internal.datatomodeladapter.TemporaryModelHandler
ToleranceCanBeMet
BoundsModifiedToType
    end

    methods
        function this=Problem(functionToApproximate,varargin)
            FunctionApproximation.internal.Utils.licenseCheck();
            p=inputParser;
            p.KeepUnmatched=1;
            addOptional(p,'Options',FunctionApproximation.Options);

            parse(p,varargin{:});
            options=p.Results.Options;
            if isempty(options)
                options=FunctionApproximation.Options;
            end

            [success,diagnostic,modifiedFunction]=FunctionApproximation.internal.Utils.validateFunctionToApproximate(functionToApproximate,options);
            throwError(this,success,diagnostic);

            factory=FunctionApproximation.internal.ProblemDefinitionFactory();
            [defaultProblemDefinition,options]=factory.getProblemDefinition(modifiedFunction,options);

            propertiesToCopy={...
            'FunctionToApproximate',...
            'InputFunctionType',...
            'InputFunctionWrapper',...
            'ApproximateFunctionType',...
            'FunctionToReplace'};
            for k=1:numel(propertiesToCopy)
                this.(propertiesToCopy{k})=defaultProblemDefinition.(propertiesToCopy{k});
            end

            this.NumberOfInputs=this.InputFunctionWrapper.NumberOfDimensions;

            defaultInputTypes=defaultProblemDefinition.InputTypes;
            defaultLowerBounds=defaultProblemDefinition.InputLowerBounds;
            defaultUpperBounds=defaultProblemDefinition.InputUpperBounds;
            defaultOutputType=defaultProblemDefinition.OutputType;

            if this.NumberOfInputs>options.MaxNumDim||this.NumberOfInputs<1
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:inputDimensionsMustBeLessThan',this.NumberOfInputs,options.MaxNumDim));
                throwError(this,false,diagnostic);
            end

            this.Options=options;
            this=setWordLengthsOnOptions(this);


            if isempty(defaultInputTypes)
                defaultInputTypes=repmat(numerictype('double'),1,this.NumberOfInputs);
            end

            addOptional(p,'InputTypes',defaultInputTypes);
            parse(p,varargin{:});
            this.InputTypes=p.Results.InputTypes;


            if isempty(defaultOutputType)
                defaultOutputType=numerictype('double');
            end

            addOptional(p,'OutputType',defaultOutputType);
            parse(p,varargin{:});
            this.OutputType=p.Results.OutputType;


            addOptional(p,'InputLowerBounds',defaultLowerBounds);
            parse(p,varargin{:});
            this.InputLowerBounds=p.Results.InputLowerBounds;


            addOptional(p,'InputUpperBounds',defaultUpperBounds);
            parse(p,varargin{:});
            this.InputUpperBounds=p.Results.InputUpperBounds;


            unmatchedFields=fieldnames(p.Unmatched);
            if~isempty(unmatchedFields)
                warning(message('SimulinkFixedPoint:functionApproximation:unmatchedFields',class(this),FunctionApproximation.internal.DisplayUtils.getUnmatchedFieldsString(unmatchedFields)));
            end

            if~isempty(this.FunctionToReplace)
                blockData=FunctionApproximation.internal.serializabledata.BlockDataWithoutCompile();
                blockData=blockData.update(this.FunctionToReplace);
                dataToModelAdapter=FunctionApproximation.internal.datatomodeladapter.BlockDataToModel();
                modelInfo=dataToModelAdapter.getModelInfo(blockData);
                handler=FunctionApproximation.internal.datatomodeladapter.TemporaryModelHandler();
                handler.registerModelInfo(modelInfo);
                this.TemporaryModelHandler=handler;
            end

            this.BoundsModifiedToType=false(1,this.NumberOfInputs);
        end

        function solutionObject=solve(this)
            curDir=pwd;
            tempDirHandler=FunctionApproximation.internal.ApproximateGeneratorEngine.initializeTempDir();
            cleanup=onCleanup(@()FunctionApproximation.internal.ApproximateGeneratorEngine.engineCleanup(tempDirHandler,curDir));

            this=getWellDefinedProblem(this);
            [isValid,diagnostic,this]=validateBeforeSolve(this);
            throwError(this,isValid,diagnostic);



            approximationEngine=FunctionApproximation.internal.getEngine(this);
            [engineDiagnostic,solutionObject]=approximationEngine.run();

            throwError(this,~isempty(solutionObject.ID),engineDiagnostic);
            FunctionApproximation.internal.DisplayUtils.displayBestSolutionAfterSolve(solutionObject,this.Options);
            throwWarning(this,isempty(engineDiagnostic),engineDiagnostic);

        end
    end

    methods(Hidden)
        function this=setClipping(this)
            minTableValue=min(this.SampledTableData(:));
            maxTableValue=max(this.SampledTableData(:));
            toleranceCheck=abs(maxTableValue-minTableValue)*2^-3;
            if(ismember('UseClipping',this.Options.DefaultFields))...
                &&(this.Options.AbsTol>=toleranceCheck)


                this.Options=FunctionApproximation.internal.ProblemDefinitionFactory.setOptionsProperty(this.Options,'UseClipping',true);
            end

            if ismember('UseClipping',this.Options.DefaultFields)...
                &&this.Options.Interpolation=="Flat"


                this.Options=FunctionApproximation.internal.ProblemDefinitionFactory.setOptionsProperty(this.Options,'UseClipping',false);
            end
        end

        function wellDefinedProblem=getWellDefinedProblem(illDefinedProblem)
            converter=FunctionApproximation.internal.IllDefinedToWellDefinedProblemConverter();
            wellDefinedProblem=converter.convert(illDefinedProblem);
        end

        function[isValid,diagnostic,this]=validateBeforeSolve(this)
            currentDefaultFields=this.Options.DefaultFields;
            isValid=true;
            diagnostic=MException.empty();

            if this.Options.ApproximateSolutionType==FunctionApproximation.internal.ApproximateSolutionType.MATLAB
                [isValid,diagnostic]=FunctionApproximation.internal.Utils.isProblemValidForMATLAB(this);
                throwError(this,isValid,diagnostic);
            end

            if this.Options.AUTOSARCompliant
                [isValid,diagnostic]=FunctionApproximation.internal.Utils.isProblemAUTOSARCompliant(this);
                throwError(this,isValid,diagnostic);
            end

            if this.Options.HDLOptimized
                [isValid,diagnostic]=FunctionApproximation.internal.Utils.isProblemValidForHDLOptimizedMode(this);
                throwError(this,isValid,diagnostic);
            end

            if(this.Options.Interpolation=="None")



                this.ToleranceCanBeMet=true;
            else
                absOriginal=abs(this.SampledTableData(:));
                errorBoundVector=max(this.Options.AbsTol,this.Options.RelTol*absOriginal);
                maxBound=FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(this.OutputType);
                toleranceCannotBeMet=any(errorBoundVector<maxBound);
                if toleranceCannotBeMet
                    this.ToleranceCanBeMet=false;
                    if this.InputFunctionType~="LUTBlock"
                        if isValid
                            isValid=false;
                            lowestOutputTypeTolerance=FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(this.OutputType);
                            diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:absTolMustBeGreaterThan',num2str(lowestOutputTypeTolerance)));
                            diagnostic=diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:outputTypePrecisionInsufficient')));
                        end
                    end
                else
                    [isValid,diagnostic]=validateTableDataForFlatAndNearestInterpolation(this);
                    this.ToleranceCanBeMet=isValid;
                end
            end


            this=updateBreakpointSpecification(this);


            this=setClipping(this);

            explicitValues=this.Options.BreakpointSpecification==FunctionApproximation.BreakpointSpecification.ExplicitValues;
            if any(explicitValues)
                if this.NumberOfInputs>1
                    FunctionApproximation.internal.DisplayUtils.displayExplicitValuesOnlyFor1D(this.Options);
                    this.Options.BreakpointSpecification(explicitValues)=[];
                elseif this.Options.HDLOptimized
                    FunctionApproximation.internal.DisplayUtils.displayUnableToSearchExplicitValuesForHDLOptimized(this.Options);
                    this.Options.BreakpointSpecification(explicitValues)=[];
                end
            end

            this.Options.DefaultFields=currentDefaultFields;
        end

        function throwError(~,isValid,diagnostic)
            if~isValid
                FunctionApproximation.internal.DisplayUtils.throwError(diagnostic);
            end
        end

        function throwWarning(~,isValid,diagnostic)
            if~isValid
                FunctionApproximation.internal.DisplayUtils.throwWarning(diagnostic);
            end
        end
    end

    methods(Access=private)
        function this=updateBreakpointSpecification(this)
            if this.Options.Interpolation=="None"
                this.Options.BreakpointSpecification="EvenSpacing";
            else
                if~this.Options.UseBPSpecAsIs&&~this.Options.AUTOSARCompliant

                    this=updateOptionsForExplicitValues(this);
                    this=updateOptionsForEvenSpacing(this);
                end
            end
        end

        function this=updateOptionsForExplicitValues(this)


            if ismember(FunctionApproximation.BreakpointSpecification.ExplicitValues,this.Options.BreakpointSpecification)
                this.Options.BreakpointSpecification=unique([this.Options.BreakpointSpecification,FunctionApproximation.BreakpointSpecification.EvenSpacing]);
            end
        end

        function this=updateOptionsForEvenSpacing(this)





            if ismember(FunctionApproximation.BreakpointSpecification.EvenSpacing,this.Options.BreakpointSpecification)
                useEvenPow2Spacing=true;
                for ii=1:this.NumberOfInputs
                    typeRange=double(fixed.internal.type.finiteRepresentableRange(this.InputTypes(ii)));
                    if(this.InputLowerBounds(ii)==typeRange(1))&&(this.InputUpperBounds(ii)==typeRange(2))
                        useEvenPow2Spacing=false;
                        break;
                    end
                end

                if useEvenPow2Spacing
                    this.Options.BreakpointSpecification=unique([this.Options.BreakpointSpecification,FunctionApproximation.BreakpointSpecification.EvenPow2Spacing]);
                end
            end
        end

        function this=setWordLengthsOnOptions(this)



            setWLs=any(ismember(this.Options.DefaultFields,'WordLengths'))...
            &&isBlock(this.InputFunctionType)...
            &&(this.InputFunctionType~="MathBlock");
            if setWLs



                hCon=SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraintFactory.getConstraint(this.FunctionToApproximate);
                wls=hCon.ChildConstraint.SpecificWL;
                multiWord=double(hCon.Multiword.WordLength);
                [~,finalWLs]=SimulinkFixedPoint.AutoscalerConstraints.mergeVectors(wls,1:multiWord);
                this.Options.WordLengths=finalWLs;
            end
        end

        function[isValid,diagnostic]=validateTableDataForFlatAndNearestInterpolation(this)
            isValid=true;
            diagnostic=MException.empty;
            if this.InputFunctionType==FunctionApproximation.internal.FunctionType.LUTBlock
                isFlat=strcmp(this.InputFunctionWrapper.Data.InterpolationMethod,'Flat');
                isNearest=strcmp(this.InputFunctionWrapper.Data.InterpolationMethod,'Nearest');
                if isFlat||isNearest
                    scaleFactor=isFlat*1+isNearest*0.5;

                    tableData=this.InputFunctionWrapper.Data.Data{end};
                    if isrow(tableData)

                        tableData=tableData';
                    end

                    maxDiff=-Inf;
                    for ii=1:this.InputFunctionWrapper.NumberOfDimensions
                        dimensionDiff=diff(tableData,1,ii);
                        maxDiff=max(max(dimensionDiff(:)),maxDiff);
                    end

                    minAbsTol=maxDiff*scaleFactor;
                    if minAbsTol>this.Options.AbsTol
                        isValid=false;
                        diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:absTolMustBeGreaterThan',num2str(minAbsTol)));
                    end
                end
            end
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(this)
            propgrp(1)=getPropertyGroups@FunctionApproximation.internal.ProblemDefinition(this);
        end
    end
end
