classdef LosslessCompressionSolver<FunctionApproximation.internal.solvers.SolverInterface






    properties(SetAccess=private)
InputTypes
OutputType
LUTModelData
InterfaceTypesMatch
ExtremaStrategy
BruteForceGrid
AnyTypeSlopeAndBias
    end

    properties(SetAccess={?FunctionApproximation.internal.solvers.LosslessCompressionSolver,...
        ?FunctionApproximation.internal.ApproximateLUTGeneratorEngine,...
        ?SolverTestCase})
TableDataRangeObject
ValidationRangeObject
    end

    methods
        function solve(this)
            if~(this.AnyTypeSlopeAndBias&&~this.InterfaceTypesMatch)
                dbUnit=FunctionApproximation.internal.database.getLUTDBUnitFromLUTModelData(this.LUTModelData);
                dbUnit.ConstraintValueMustBeLessThan=[this.Options.AbsTol,this.Options.MaxMemoryUsageBits];
                addDBUnit(this,dbUnit,true);


                converter=FunctionApproximation.internal.losslessdatatypeconverter.getConverter(this.Options);
                [addUnit,newDBUnit]=converter.convert(dbUnit,this.Options);
                if addUnit

                    addDBUnit(this,newDBUnit,false);
                end
            end
        end
    end

    methods(Hidden)
        function addDBUnit(this,dbUnit,isCopyOfOriginal)
            if~hasDBUnit(this.DataBase,dbUnit,"Full")


                if this.Options.AUTOSARCompliant

                    interfaceTypes=[this.InputTypes,this.OutputType];
                    registerDBUnit=FunctionApproximation.internal.Utils.isLUTDBunitAUTOSARCompliant(dbUnit,interfaceTypes);
                else

                    registerDBUnit=true;
                end






                if~this.InterfaceTypesMatch||~isCopyOfOriginal
                    dbUnit.SerializeableData.ExtrapolationMethod='Clip';
                    dbUnit=updateErrorOnDBUnit(this,dbUnit);
                end

                if registerDBUnit
                    this.DataBase.add(dbUnit);
                end
            end
        end

        function registerDependencies(this,problemObject)
            this.InputTypes=problemObject.InputTypes;
            this.OutputType=problemObject.OutputType;
            this.LUTModelData=FunctionApproximation.internal.Utils.getLUTDataForFunctionToApproximate(problemObject);
            this.InterfaceTypesMatch=isequal(fixed.internal.type.extractNumericType(this.LUTModelData.OutputType),this.OutputType);
            for iType=1:numel(this.InputTypes)
                this.InterfaceTypesMatch=this.InterfaceTypesMatch&&isequal(fixed.internal.type.extractNumericType(this.LUTModelData.InputTypes(iType)),this.InputTypes(iType));
                if~this.InterfaceTypesMatch
                    break;
                end
            end
            this.LUTModelData.InputTypes=this.InputTypes;
            this.LUTModelData.OutputType=this.OutputType;
            approximation=FunctionApproximation.internal.getWrapper(this.LUTModelData,this.Options);
            this.ErrorFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(...
            problemObject.InputFunctionWrapper,approximation,...
            this.Options.AbsTol,this.Options.RelTol);

            if this.InterfaceTypesMatch

                singleDimensionDomains=this.LUTModelData.Data(1:end-1);
                for ii=1:problemObject.NumberOfInputs
                    internalPoints=singleDimensionDomains{ii}(:)';
                    singleDimensionDomains{ii}=unique([problemObject.InputLowerBounds(ii),internalPoints,problemObject.InputUpperBounds(ii)]);
                end
                bruteForceGridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(this.InputTypes);
                this.BruteForceGrid=FunctionApproximation.internal.Grid(singleDimensionDomains,bruteForceGridCreator);

                extremaStrategyFactory=FunctionApproximation.internal.extremastrategy.ExtremaStrategyFactory();
                this.ExtremaStrategy=extremaStrategyFactory.getStrategy(true,problemObject.NumberOfInputs);
            else
                bruteForceGridingStrategyFactory=FunctionApproximation.internal.gridcreator.GridingStrategyFactory();
                bruteForceGridCreator=bruteForceGridingStrategyFactory.getMaximumPointsGridStrategy(problemObject.IsGridExhaustive,this.InputTypes);
                bruteForceGrid=bruteForceGridCreator.getGrid(this.ValidationRangeObject,[]);
                this.BruteForceGrid=FunctionApproximation.internal.Grid(bruteForceGrid,bruteForceGridCreator);

                extremaStrategyFactory=FunctionApproximation.internal.extremastrategy.ExtremaStrategyFactory();
                this.ExtremaStrategy=extremaStrategyFactory.getStrategy(problemObject.IsGridExhaustive,problemObject.NumberOfInputs);
            end

            this.AnyTypeSlopeAndBias=any(arrayfun(@(x)x.isscalingslopebias,[this.InputTypes,this.OutputType]));
        end

        function dbUnit=updateErrorOnDBUnit(this,dbUnit)
            maximaFinder=FunctionApproximation.internal.getExtremaFinder(this.ExtremaStrategy,'Maximize');
            inputWLs=arrayfun(@(x)x.WordLength,this.InputTypes);
            sumInputWLs=sum(inputWLs);
            this.ErrorFunction.modify(dbUnit.SerializeableData);
            [errorAt,currentError]=getExtrema(maximaFinder,this.ErrorFunction,...
            this.BruteForceGrid,sumInputWLs);
            dbUnit.ConstraintAt=errorAt;
            dbUnit.ConstraintValue(1)=currentError;
        end
    end
end
