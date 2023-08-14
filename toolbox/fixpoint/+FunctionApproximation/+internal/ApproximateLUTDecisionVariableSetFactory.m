classdef ApproximateLUTDecisionVariableSetFactory







    methods
        function decisionVariableSets=getApproximateLUTDecisionVariableSet(this,problemObject,options)

            [wordlengthUpperBounds,wlTightFiTruncated]=this.getWLUpperBounds(problemObject,options);


            constraintGenerator=FunctionApproximation.internal.solvers.WLConstraintGeneratorFactory.getConstraintGenerator(options);
            constraints=constraintGenerator.getConstraints(problemObject,options);
            wlCombinationGenerator=FunctionApproximation.internal.solvers.WLCombinationGeneratorFactory.getGenerator(options);
            wordLengthCombinations=wlCombinationGenerator.getCombinations(...
            options.WordLengths,constraints,wordlengthUpperBounds);



            wordLengthCombinations=this.reOrderWLCombinationsUsingUpperBounds(wordLengthCombinations,wordlengthUpperBounds);


            wordLengthCombinations=this.filterWLCombinationsUsingMemoryUsage(wordLengthCombinations,problemObject);


            if~isempty(wordLengthCombinations)
                tableData=this.getTableData(problemObject);
                valueForToleranceCheck=this.getValueForToleranceCheck(problemObject,options);
                toleranceCheckFactor=this.getToleranceCheckFactor(wordLengthCombinations,tableData,valueForToleranceCheck,problemObject.OutputType);
                wlMap=this.getWLMap(wordLengthCombinations,wordlengthUpperBounds(end),wlTightFiTruncated);
                toleranceToMeet=toleranceCheckFactor*valueForToleranceCheck;
                [wordLengthCombinations,maxRatio]=...
                this.filterWLUsingSampleData(wordLengthCombinations,...
                problemObject,options,toleranceToMeet,wlMap,tableData);
                originalFunctionIsBlock=isBlock(problemObject.InputFunctionType);
                wordLengthCombinations=this.randomizeWLCombinations(wordLengthCombinations,maxRatio,originalFunctionIsBlock);
            end


            dvSetBuilder=FunctionApproximation.internal.solvers.LUTDecisionVariableSetBuilderFactory.getBuilder(options);
            matchInterfaceTypes=cellfun(@(x)~isempty(x),constraints);
            dvSetBuilder.build(wordLengthCombinations,problemObject,matchInterfaceTypes);
            decisionVariableSets=dvSetBuilder.DecisionVariableSets;
        end
    end

    methods(Static)
        function wlCombinations=randomizeWLCombinations(wlCombinations,maxRatio,isBlock)
            numDimensions=size(wlCombinations,2)-1;
            if isBlock
                numInitialToExcludePerDimension=4;
            else
                numInitialToExcludePerDimension=8;
            end
            startPoint=numInitialToExcludePerDimension*numDimensions+1;
            wordLengthCombinations=wlCombinations(startPoint:end,:);
            maxRatio=maxRatio(startPoint:end);
            if~isempty(wordLengthCombinations)

                locEdgeCases=maxRatio>0.99;
                locRegularCases=~locEdgeCases;
                edgeCaseIndices=find(locEdgeCases);
                nEdgeCases=numel(edgeCaseIndices);
                regularCaseIndices=find(locRegularCases);
                nRegularCases=numel(regularCaseIndices);
                maxNForShuffle=min(nEdgeCases,nRegularCases);
                if maxNForShuffle>1


                    originalRNG=rng(0,'twister');
                    shuffledIndices=randperm(maxNForShuffle);
                    rng(originalRNG);
                    tmpWL=wordLengthCombinations(edgeCaseIndices(1:maxNForShuffle),:);
                    wordLengthCombinations(edgeCaseIndices(1:maxNForShuffle),:)=wordLengthCombinations(regularCaseIndices(shuffledIndices),:);
                    wordLengthCombinations(regularCaseIndices(1:maxNForShuffle),:)=tmpWL(shuffledIndices,:);
                end
                wlCombinations(startPoint:end,:)=wordLengthCombinations;
            end
        end

        function validCombinations=reOrderWLCombinationsUsingUpperBounds(validCombinations,wordlengthUpperBounds)
            if any(validCombinations(:)>18)



                fastSolveIndices=sum(validCombinations(:,1:end-1),2)<=18;
                smallWLValidationCombination=validCombinations(fastSolveIndices,:);

                largeWLValidationCombination=validCombinations(~fastSolveIndices,:);

                [~,indices]=sort(sum(abs(largeWLValidationCombination-wordlengthUpperBounds),2));
                largeWLValidationCombination=largeWLValidationCombination(indices,:);

                validCombinations=[smallWLValidationCombination;largeWLValidationCombination];
            end
        end

        function wlMap=getWLMap(validCombinations,wlUB,wlTightFiTruncated)
            wlMap=containers.Map('KeyType','double','ValueType','double');
            uniqueTableWLs=unique(validCombinations(:,end));
            for k=1:numel(uniqueTableWLs)
                tableTypeWL=uniqueTableWLs(k);
                if(wlTightFiTruncated&&(tableTypeWL==wlUB))
                    wlMap(tableTypeWL)=1;
                else
                    wlMap(tableTypeWL)=-1;
                end
            end
        end

        function tableData=getTableData(problemObject)
            if problemObject.InputFunctionType==FunctionApproximation.internal.FunctionType.LUTBlock
                serializeableData=problemObject.InputFunctionWrapper.Data;
                tableData=serializeableData.Data{end};
            else
                tableData=problemObject.SampledTableData;
            end
        end

        function valueForToleranceCheck=getValueForToleranceCheck(problemObject,options)
            if problemObject.InputFunctionType==FunctionApproximation.internal.FunctionType.LUTBlock


                serializeableData=problemObject.InputFunctionWrapper.Data;
                valueForToleranceCheck=max(options.AbsTol,FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(serializeableData.StorageTypes(end)));
            else
                valueForToleranceCheck=options.AbsTol;
            end
        end

        function validCombinations=filterWLCombinationsUsingMemoryUsage(validCombinations,problemObject)
            if problemObject.InputFunctionType==FunctionApproximation.internal.FunctionType.LUTBlock


                serializeableData=problemObject.InputFunctionWrapper.Data;
                filterObject=FunctionApproximation.internal.solvers.FilterWLCombinationsUsingMemoryUsage();
                validCombinations=filterObject.filter(validCombinations,serializeableData);
            end
        end

        function[wordlengthUpperBounds,wlTightFiTruncated]=getWLUpperBounds(problemObject,options)
            inputWordLengths=arrayfun(@(x)x.WordLength,problemObject.InputTypes);
            wordlengthUpperBounds=[inputWordLengths,problemObject.OutputType.WordLength];
            wlTightFiTruncated=false;
            if problemObject.InputFunctionType==FunctionApproximation.internal.FunctionType.LUTBlock

                wlTightFiTruncated=true;
                serializeableData=problemObject.InputFunctionWrapper.Data;
                if options.Interpolation=="Nearest"


                    indices=(serializeableData.NumberOfDimensions+1);
                else
                    indices=1:(serializeableData.NumberOfDimensions+1);
                end

                for ii=indices
                    [isValid,snappedWL]=FunctionApproximation.internal.getWlUsingTightDataType(...
                    fixed.internal.math.castUniversal(serializeableData.Data{ii},serializeableData.StorageTypes(ii)),...
                    wordlengthUpperBounds(ii),...
                    options);

                    if isValid
                        wordlengthUpperBounds(ii)=snappedWL;
                    end
                end
            else

                if problemObject.IsGridExhaustive
                    [isValid,snappedWL]=FunctionApproximation.internal.getWlUsingTightDataType(...
                    fixed.internal.math.castUniversal(problemObject.SampledTableData,problemObject.OutputType),...
                    wordlengthUpperBounds(end),...
                    options);

                    if isValid
                        wordlengthUpperBounds(end)=snappedWL;
                        wlTightFiTruncated=true;
                    end
                end
            end
        end

        function toleranceCheckFactor=getToleranceCheckFactor(wordLengthCombinations,tableData,valueForToleranceCheck,outputType)
            toleranceCheckFactor=1;
            if~isempty(wordLengthCombinations)




                dataType=FunctionApproximation.internal.scaleDataType(numerictype(1,max(wordLengthCombinations(:,end)),4),tableData,outputType);
                if~FunctionApproximation.internal.Utils.canDataTypeMeetTolerance(dataType,valueForToleranceCheck)
                    toleranceCheckFactor=3;
                end
            end
        end

        function[wlCombinations,maxRatio]=filterWLUsingSampleData(wlCombinations,problemObject,options,toleranceToMeet,wlMap,tableData)
            if~isempty(wlCombinations)

                nCombinations=size(wlCombinations,1);
                indicesToInclude=true(nCombinations,1);


                ratios=containers.Map(wlMap.keys,zeros(wlMap.Count,1));
                maxRatio=zeros(nCombinations,1);
                for k=1:nCombinations
                    tableTypeWL=wlCombinations(k,end);
                    if(wlMap(tableTypeWL)==-1)
                        dataType=FunctionApproximation.internal.scaleDataType(...
                        numerictype(1,tableTypeWL,4),tableData,...
                        problemObject.OutputType);
                        wlMap(tableTypeWL)=true;


                        if~FunctionApproximation.internal.Utils.canDataTypeMeetTolerance(dataType,toleranceToMeet)


                            originalValues=tableData(:);
                            approximateValues=double(fixed.internal.math.castUniversal(originalValues,dataType));
                            absError=abs(originalValues-approximateValues);
                            upperBound=max(options.AbsTol,options.RelTol*abs(originalValues));
                            checks=(absError>upperBound);
                            ratios(tableTypeWL)=max(absError./upperBound);
                            wlMap(tableTypeWL)=~any(checks);
                        end
                    end
                    indicesToInclude(k)=wlMap(tableTypeWL);
                    maxRatio(k)=ratios(tableTypeWL);
                end
                wlCombinations=wlCombinations(indicesToInclude,:);
                maxRatio=maxRatio(indicesToInclude);
            end
        end
    end
end


