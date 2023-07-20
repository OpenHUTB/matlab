classdef DirectLUSolver<FunctionApproximation.internal.solvers.SolverInterface




    properties(SetAccess=private)
InputTypes
OutputType
NumberOfDimensions
ValidationRangeObject
TableDataRangeObject
Grid
InputFunctionWrapper
    end

    methods
        function solve(this,combinations)

            testVector=getSets(this.Grid);


            for ii=1:numel(combinations)
                intermediateTypes=combinations(ii).StorageTypes;
                intermediateWLS=arrayfun(@(x)x.WordLength,intermediateTypes);


                dataTypes=intermediateTypes(1:end-1);
                gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(dataTypes);
                singleDimensionDomains=this.getSingleDimensionDomains(...
                dataTypes,...
                this.TableDataRangeObject,...
                this.InputTypes);
                gridObject=FunctionApproximation.internal.Grid(singleDimensionDomains,gridCreator);


                tableDataWL=intermediateWLS(end);
                numTableValues=prod(gridObject.GridSize);
                currentObjectiveValue=numTableValues*tableDataWL;


                proceedWithValidation=this.HardConsTracker.advance()...
                &&(currentObjectiveValue<=this.MaxObjectiveValue);

                if proceedWithValidation
                    tableData=this.getTableData(this.InputFunctionWrapper,gridObject);

                    if~FunctionApproximation.internal.isNaNOrInf(tableData)
                        intermediateTypes(end)=FunctionApproximation.internal.scaleDataType(intermediateTypes(end),tableData,this.OutputType);
                        serializeableData=FunctionApproximation.internal.serializabledata.DirectLUData();
                        serializeableData=serializeableData.update(...
                        this.InputTypes,...
                        this.OutputType,...
                        tableData,...
                        [this.TableDataRangeObject.Minimum',this.TableDataRangeObject.Maximum'],...
                        intermediateTypes);


                        dbUnit=FunctionApproximation.internal.database.DirectLUDBUnit();
                        dbUnit.GridSize=gridObject.GridSize;
                        dbUnit.ConstraintAt=[];
                        dbUnit.ConstraintValue=[];
                        dbUnit.ConstraintValueMustBeLessThan=[this.Options.AbsTol,this.Options.MaxMemoryUsageBits];
                        dbUnit.ObjectiveValue=currentObjectiveValue;
                        dbUnit.BreakpointSpecification=FunctionApproximation.BreakpointSpecification.EvenSpacing;
                        dbUnit.Grid=gridObject;
                        dbUnit.StorageTypes=intermediateTypes;
                        dbUnit.SerializeableData=serializeableData;

                        if~hasDBUnit(this.DataBase,dbUnit,"Partial")
                            passed=checkWithGriddedInterpolant(this,singleDimensionDomains,testVector);
                            if passed

                                approximationWrapper=FunctionApproximation.internal.getWrapper(serializeableData,this.Options);
                                this.ErrorFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(...
                                this.InputFunctionWrapper,...
                                approximationWrapper,...
                                this.Options.AbsTol,this.Options.RelTol);

                                outputValues=this.ErrorFunction.evaluate(testVector);
                                [value,currentErrorIndex]=max(outputValues);
                                currentErrorAt=testVector(currentErrorIndex,:);
                                checkOriginalFunctionOverflow(this,currentErrorAt);

                                dbUnit.ConstraintValue=[value,currentObjectiveValue];
                                dbUnit.ConstraintAt=currentErrorAt;
                                if dbUnit.ConstraintMet
                                    this.ObjectiveValue=min(dbUnit.ObjectiveValue,this.ObjectiveValue);
                                end
                                this.DataBase.add(dbUnit);
                                if dbUnit.IndividualConstraintMet(1)
                                    updateObjectiveValue(this);
                                end
                            end
                        end
                    end
                end

                if~this.SoftConsTracker.advance()
                    break;
                end
            end
        end

        function updateObjectiveValue(this)
            dbUnits=getFeasibleDBUnits(this.DataBase,1);
            if~isempty(dbUnits)
                currentBest=min([dbUnits.ObjectiveValue]);
                if currentBest<this.MaxObjectiveValue
                    this.MaxObjectiveValue=currentBest;
                end
            end
        end

        function passed=checkWithGriddedInterpolant(this,singleDimensionDomains,testVector)
            serializeableData=FunctionApproximation.internal.serializabledata.InterpNData();
            for i=1:numel(singleDimensionDomains)
                singleDimensionDomains{i}=unique(singleDimensionDomains{i});
            end
            testSets=FunctionApproximation.internal.CoordinateSetCreator(singleDimensionDomains).CoordinateSets;
            tableValues=this.InputFunctionWrapper.evaluate(testSets);
            gridSize=cellfun(@(x)numel(x),singleDimensionDomains);
            if numel(gridSize)==1
                tableValues=tableValues';
            else
                tableValues=reshape(tableValues,gridSize);
            end
            serializeableData=serializeableData.update([singleDimensionDomains,{tableValues}]);
            serializeableData.InterpolationMethod='nearest';
            serializeableData.ExtrapolationMethod='nearest';
            approximation=FunctionApproximation.internal.getWrapper(serializeableData);
            errFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(...
            this.InputFunctionWrapper,...
            approximation,...
            this.Options.AbsTol,...
            this.Options.RelTol);
            outputValues=errFunction.evaluate(testVector);
            value=max(outputValues);
            passed=value<=this.Options.AbsTol;
        end

        function registerDependencies(this,problemObject)

            this.NumberOfDimensions=problemObject.NumberOfInputs;
            this.ValidationRangeObject=FunctionApproximation.internal.Range(...
            problemObject.InputLowerBounds,...
            problemObject.InputUpperBounds);
            this.TableDataRangeObject=FunctionApproximation.internal.Range(...
            problemObject.InputLowerBounds,...
            problemObject.InputUpperBounds);
            this.InputTypes=problemObject.InputTypes;
            this.OutputType=problemObject.OutputType;
            this.OutputTypeRange=double(fixed.internal.type.finiteRepresentableRange(problemObject.OutputType));
            this.InputFunctionWrapper=problemObject.InputFunctionWrapper;
            dataTypes=problemObject.InputTypes;
            gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(dataTypes);
            nDimensions=this.NumberOfDimensions;
            singleDimensionDomains=cell(1,nDimensions);
            for iDim=1:nDimensions
                [minValue,maxValue]=getMinMaxForDimension(this.TableDataRangeObject,iDim);
                minFi=fi(minValue,dataTypes(iDim),'RoundMode','Floor');
                maxFi=fi(maxValue,dataTypes(iDim),'RoundMode','Ceiling');
                minFiSI=minFi.storedIntegerToDouble;
                maxFiSI=maxFi.storedIntegerToDouble;
                singleDimensionDomains{iDim}=double(fi([],dataTypes(iDim),'int',minFiSI:maxFiSI));
            end
            this.Grid=FunctionApproximation.internal.Grid(singleDimensionDomains,gridCreator);
        end
    end

    methods(Static)
        function tableData=getTableData(functionWrapper,gridObject)
            cellOfGrids=gridObject.SingleDimensionDomains;

            sets=FunctionApproximation.internal.CoordinateSetCreator(cellOfGrids).CoordinateSets;
            shape=gridObject.GridSize;
            if numel(shape)==1
                shape=[gridObject.GridSize,1];
            end

            warningStruct=warning('off');
            tableData=reshape(functionWrapper.evaluate(sets),shape);
            warning(warningStruct);
        end

        function singleDimensionDomains=getSingleDimensionDomains(dataTypes,rangeObject,inputTypes)
            nDimensions=numel(dataTypes);
            singleDimensionDomains=cell(1,nDimensions);
            for iDim=1:nDimensions
                [minValue,maxValue]=getMinMaxForDimension(rangeObject,iDim);
                minFi=fi(minValue,dataTypes(iDim),'RoundMode','Floor');
                maxFi=fi(maxValue,dataTypes(iDim),'RoundMode','Ceiling');
                minFiSI=minFi.storedIntegerToDouble;
                maxFiSI=max(maxFi.storedIntegerToDouble,minFiSI+1);
                if minFiSI==(-1^inputTypes(iDim).Signed)*2^(inputTypes(iDim).WordLength-1)
                    gridPoints=double(fi([],dataTypes(iDim),'int',[max(0,minFiSI):maxFiSI,minFiSI:min(-1,maxFiSI)]));
                else
                    gridPoints=double(fi([],dataTypes(iDim),'int',minFiSI:maxFiSI));
                end


                nPoints=ceil(log2(numel(gridPoints)));
                tmpVec=repmat(gridPoints(end),1,2^nPoints);
                tmpVec(1:numel(gridPoints))=gridPoints;
                singleDimensionDomains{iDim}=tmpVec;
            end
        end
    end
end


