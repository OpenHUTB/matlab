classdef ApproximateLUTSolution<FunctionApproximation.internal.ApproximateSolution








    properties(Hidden,SetAccess=private)
        TableDataLocal=[]
        CompareContext FunctionApproximation.internal.visualizer.DataContext
    end

    methods(Access={?FunctionApproximation.internal.LUTDBUnitToApproximateLUTSolutionAdapter,?ApproximateSolutionTestCase})
        function this=ApproximateLUTSolution()
        end
    end

    methods
        function solution=solutionfromID(this,ID)
            ids=getAllIDs(this.DataBase);
            if~isnumeric(ID)||(isnumeric(ID)&&(ID>max(ids)))
                FunctionApproximation.internal.DisplayUtils.throwError(...
                MException(message('SimulinkFixedPoint:functionApproximation:invalidIDToGetSolution',sprintf('[%g:%g]',min(ids),max(ids)))));
            end

            adapter=FunctionApproximation.internal.LUTDBUnitToApproximateLUTSolutionAdapter;
            solution=adapter.createSolution(this.DataBase.getDBUnitFromID(ID),this.SourceProblem,this.Options,this.DataBase);
        end

        function solutions=allsolutions(this)
            dbUnits=getAllDBUnits(this.DataBase);
            solutions=[];
            for ii=1:numel(dbUnits)
                solutions=[solutions,solutionfromID(this,dbUnits(ii).ID)];%#ok<AGROW>
            end
        end

        function displayallsolutions(this)
            dbUnits=getAllDBUnits(this.DataBase);
            if~isempty(dbUnits)
                FunctionApproximation.internal.DisplayUtils.displayDBUnitHeader(dbUnits(1),this.Options);
                for ii=1:numel(dbUnits)
                    FunctionApproximation.internal.DisplayUtils.displayDBUnit(dbUnits(ii),this.Options);
                end
                FunctionApproximation.internal.DisplayUtils.displayBestSolution(this.DataBase.getBest(dbUnits),this.Options);
            end
        end

        function solutions=feasiblesolutions(this)
            dbUnits=getFeasibleDBUnits(this.DataBase);
            solutions=[];
            for ii=1:numel(dbUnits)
                solutions=[solutions,solutionfromID(this,dbUnits(ii).ID)];%#ok<AGROW>
            end
        end

        function displayfeasiblesolutions(this)
            dbUnits=getFeasibleDBUnits(this.DataBase);
            if~isempty(dbUnits)
                FunctionApproximation.internal.DisplayUtils.displayDBUnitHeader(dbUnits(1),this.Options);
                for ii=1:numel(dbUnits)
                    FunctionApproximation.internal.DisplayUtils.displayDBUnit(dbUnits(ii),this.Options);
                end
                FunctionApproximation.internal.DisplayUtils.displayBestSolution(this.DataBase.getBestFeasible(dbUnits),this.Options);
            end
        end

        function varargout=approximate(this,varargin)
            optionsData=FunctionApproximation.internal.option.OptionsDataFactory().getOptionsDataFromOptions(this.Options);
            generator=FunctionApproximation.internal.approximategenerator.ApproximateGeneratorFactory.getApproximateGenerator(optionsData);
            result=generator.approximate(this,varargin{:});
            if nargout<2
                varargout{1}=result;
            else
                varargout{1}=result.ModelObject;
                varargout{2}=result.BlockObject;
            end
        end

        function data=tabledata(this)
            if isempty(this.TableDataLocal)
                data=this.ErrorFunction.Approximation.Data;
                if this.Options.Interpolation=="None"
                    breakpointTypes=data.IntermediateTypes(1:end-1);
                    tableDataType=data.IntermediateTypes(end);
                    tableValues=data.Data;
                    breakpointValues={this.DBUnit.Grid.SingleDimensionDomains};
                    isEven=true;
                else
                    breakpointTypes=data.StorageTypes(1:end-1);
                    tableDataType=data.StorageTypes(end);
                    isEven=isEvenSpacing(data.Spacing);
                    tableValues=data.Data{end};
                    breakpointValues={data.Data(1:end-1)};
                end
                this.TableDataLocal=struct('BreakpointValues',breakpointValues,...
                'BreakpointDataTypes',breakpointTypes,...
                'TableValues',tableValues,...
                'TableDataType',tableDataType,...
                'IsEvenSpacing',isEven,...
                'Interpolation',this.Options.Interpolation);
            end
            data=this.TableDataLocal;
        end

        function memoryUsage=totalmemoryusage(this,memoryUnit)



            memoryUsage=this.ErrorFunction.Approximation.Data.MemoryUsage;


            memoryUsage.Unit=memoryUnit;


            memoryUsage=memoryUsage.Value;
        end

        function errorPercentDiff=percentreduction(this)
            newMemoryUsage=this.ErrorFunction.Approximation.Data.MemoryUsage.getBits();
            if this.SourceProblem.InputFunctionType==FunctionApproximation.internal.FunctionType.LUTBlock
                oldMemoryUsage=this.SourceProblem.InputFunctionWrapper.Data.MemoryUsage.getBits();
            else
                oldMemoryUsage=0;
            end
            errorPercentDiff=100*(oldMemoryUsage-newMemoryUsage)/oldMemoryUsage;
        end

        function[success,diagnostic]=replaceWithApproximate(this,varargin)


            [success,diagnostic]=FunctionApproximation.internal.Utils.isAUTOSARBlocksetLicenseAvailable(this.Options);
            if~success
                throwAsCaller(diagnostic);
            end
            if~isempty(this.SourceProblem.FunctionToReplace)
                [success,diagnostic]=...
                FunctionApproximation.internal.Utils.replaceBlockWithLUTSolution(...
                this.SourceProblem.FunctionToReplace,this);
            else
                success=false;
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:canReplaceOnlyBlocks'));
            end
        end

        function[success,diagnostic]=revertToOriginal(this,varargin)
            if~isempty(this.SourceProblem.FunctionToReplace)
                curDir=pwd;
                handler=this.SourceProblem.TemporaryModelHandler;
                loadModel(handler);
                originalBlockPath=getSourceBlockPath(handler);
                [success,diagnostic]=...
                FunctionApproximation.internal.Utils.replaceBlockWithBlock(...
                this.SourceProblem.FunctionToReplace,originalBlockPath);
                close_system(handler.ModelName,0);
                cd(curDir);
            else
                success=false;
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:canRevertOnlyBlocks'));
            end
        end

        function[compareData,h]=compare(this)
            if this.SourceProblem.NumberOfInputs>2

                FunctionApproximation.internal.DisplayUtils.throwError(...
                MException(message('SimulinkFixedPoint:functionApproximation:comparisonNotPossibleGreaterThan2D')));
            end


            loadCompareContext(this);


            plotter=FunctionApproximation.internal.visualizer.PlotterFactory.getPlotter(this.SourceProblem.NumberOfInputs);


            h=plotter.plot(this.CompareContext);


            compareData=struct(...
            'Breakpoints',this.CompareContext.Breakpoints,...
            'Original',this.CompareContext.Original,...
            'Approximate',this.CompareContext.Approximate);
        end

        function bestSolution=getBestWithSpacing(this,spacing)
            bestSolution=[];
            allUnits=getAllDBUnits(this.DataBase);
            bpSpec=[allUnits.BreakpointSpecification];
            nUnits=numel(allUnits);
            matching=false(nUnits,1);
            for ii=1:nUnits
                matching(ii)=any(bpSpec(ii)==spacing);
            end
            unitsMatchingSpacing=allUnits(matching);
            bestUnit=this.DataBase.getBest(unitsMatchingSpacing);
            if~isempty(bestUnit)
                bestSolution=this.solutionfromID(bestUnit.ID);
            end
        end
    end

    methods(Hidden)
        function loadCompareContext(this)
            dataCollector=FunctionApproximation.internal.visualizer.DataCollectorFactory.getDataCollector(this.SourceProblem.NumberOfInputs);
            if isempty(this.CompareContext)&&~isempty(dataCollector)
                currentErrorFunction=this.ErrorFunction;
                originalFunctionWrapper=this.SourceProblem.InputFunctionWrapper;
                if this.SourceProblem.InputFunctionType=="LUTBlock"
                    originalFunctionWrapper=FunctionApproximation.internal.functionwrapper.BlockWrapper(originalFunctionWrapper.Data);
                end

                data=FunctionApproximation.internal.Utils.getLUTDataForApproximateFunction(this);
                approximationWrapper=FunctionApproximation.internal.getApproximationWrapper(this.Options,data);

                this.ErrorFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(...
                originalFunctionWrapper,approximationWrapper,this.ErrorFunction.AbsTol,this.ErrorFunction.RelTol);

                this.CompareContext=collect(dataCollector,this);

                this.ErrorFunction=currentErrorFunction;
            end
        end
    end
end
