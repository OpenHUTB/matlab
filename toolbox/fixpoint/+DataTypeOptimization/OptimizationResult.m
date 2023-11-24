classdef OptimizationResult<handle&matlab.mixin.CustomDisplay

    properties(Dependent)
Model
SystemUnderDesign
    end

    properties(SetAccess=private)
FinalOutcome
OptimizationOptions
Solutions
    end

    properties(SetAccess=private,Hidden)
environmentContext
solutionsRepository
finalState
failureRateTable
    end

    properties(SetAccess=private,Hidden,Transient=true)
optimizationEngine
    end

    properties(Hidden)
sfEntries
modelState
baselineSimOut
baselineRunID
progressTracer
    end

    methods

        function this=OptimizationResult(optimizationEngine)
            this.optimizationEngine=optimizationEngine;
            this.solutionsRepository=optimizationEngine.solutionsRepository;
            this.progressTracer=optimizationEngine.progressTracer;
            this.OptimizationOptions=optimizationEngine.options;
            this.environmentContext=this.optimizationEngine.environmentProxy.context;


            this.registerResultState();






            priorDataLoggingOverride=get_param(this.Model,'DataLoggingOverride');
            this.prepareToExport();
            set_param(this.Model,'DataLoggingOverride',priorDataLoggingOverride);
        end

        function model=get.Model(this)
            model=this.environmentContext.TopModel;
        end

        function sud=get.SystemUnderDesign(this)
            sud=this.environmentContext.SUD;
        end

        function solution=explore(this,varargin)

            scenarioIndex=1;
            keepOriginalModelParameters=false;
            if(nargin==2||nargin==3)&&all(cellfun(@(x)(isnumeric(x)),varargin))
                solutionIndex=varargin{1};
                if nargin==3
                    scenarioIndex=varargin{2};
                end
            else
                p=inputParser();
                p.KeepUnmatched=true;
                p.addParameter('SolutionIndex',1);
                p.addParameter('ScenarioIndex',1);
                p.addParameter('KeepOriginalModelParameters',false);
                p.parse(varargin{:});
                if~isempty(fields(p.Unmatched))
                    DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:incorrectToleranceType');
                end
                solutionIndex=p.Results.SolutionIndex;
                scenarioIndex=p.Results.ScenarioIndex;
                keepOriginalModelParameters=p.Results.KeepOriginalModelParameters;
            end

            validateattributes(solutionIndex,{'numeric'},{'scalar','positive','real','integer','<=',numel(this.Solutions)},'explore','solutionIndex');
            mustBeNumScenarios=max(numel(this.OptimizationOptions.AdvancedOptions.SimulationScenarios),1);
            validateattributes(scenarioIndex,{'numeric'},{'scalar','positive','real','integer','<=',mustBeNumScenarios},'explore','scenarioIndex');
            solution=this.Solutions(solutionIndex);
            if this.finalState.solutionOutcome==DataTypeOptimization.SolutionOutcome.NoValidSolutionFound
                MSLDiagnostic('SimulinkFixedPoint:dataTypeOptimization:unableToExplore').reportAsWarning;
            end


            this.exploreSolution(solution,scenarioIndex,keepOriginalModelParameters);

        end

        function allSolutions=getAllSolutions(this)




            allSolutions=this.solutionsRepository.solutions.values;
            allSolutions=[allSolutions{:}];

        end

        function allSolutions=getAllValidSolutions(this)


            allSolutions=[];
            if this.finalState.solutionOutcome~=DataTypeOptimization.SolutionOutcome.NoValidSolutionFound

                allSolutions=this.solutionsRepository.solutions.values;
                validAndFullySpecified=cellfun(@(x)((x.isValid&&x.isFullySpecified)),allSolutions);
                allSolutions(~validAndFullySpecified)='';
                allSolutions=[allSolutions{:}];
                allSolutions=this.sortByIndex(allSolutions);
            end
        end

        function failureRate=getFailureRateStatistics(this)

            failureRate=this.failureRateTable;
        end

        function revert(this)

            if~isempty(this.modelState)
                this.revertSolution();
            end
        end

        function openSimulationManager(this)
            allValidSolutions=this.getAllValidSolutions();
            allSimIn=[allValidSolutions.simIn];
            allSimOut=[allValidSolutions.simOut];

            if~isempty(allSimIn)
                openSimulationManager(allSimIn,allSimOut);
                multiSimMgr=MultiSim.internal.MultiSimManager.getMultiSimManager();
                viewer=multiSimMgr.getViewerForModel(this.Model);
                viewer.Job.FigureManager.FigureObjects.Title=message('SimulinkFixedPoint:dataTypeOptimization:simManagerTitle').getString();
                viewer.Job.FigureManager.FigureObjects.XData="cost";
                viewer.Job.FigureManager.FigureObjects.XLabel=message('SimulinkFixedPoint:dataTypeOptimization:simManagerCost').getString();
                viewer.Job.FigureManager.FigureObjects.YData="maxDifferences";
                if numel(allSimOut(1).maxDifferences)>1
                    viewer.Job.FigureManager.FigureObjects.YData=viewer.Job.FigureManager.FigureObjects.YData.Id+"(1)";
                end
                viewer.Job.FigureManager.FigureObjects.YLabel=message('SimulinkFixedPoint:dataTypeOptimization:simManagerMaxDiff').getString();
                viewer.Job.FigureManager.FigureObjects.CData="float_pass";
                viewer.Job.FigureManager.FigureObjects.CLabel=message('SimulinkFixedPoint:dataTypeOptimization:simManagerPass').getString();
                viewer.Job.FigureManager.FigureObjects.YGrid="on";
                viewer.Job.FigureManager.FigureObjects.XGrid="on";
            end
        end

    end

    methods(Access=protected,Hidden)
        function footer=getFooter(obj)

            var=inputname(1);
            footer='';
            if feature('hotlinks')
                if~isempty(var)&&~isequal(obj.finalState.solutionOutcome,DataTypeOptimization.SolutionOutcome.NoValidSolutionFound)
                    footer=sprintf(...
                    '\tUse the <a href="matlab: if exist(''%s'', ''var'') && isa(%s, ''DataTypeOptimization.OptimizationResult''), DataTypeOptimization.hyperlink(%s); end">explore</a> method to explore the best found solution.\n',var,var,var);
                end
            end
        end

    end

    methods(Hidden)
        function updateResult(this,progressTracer,options)
            this.progressTracer=progressTracer;
            this.OptimizationOptions=options;


            this.registerResultState();


            this.prepareToExport();

        end

        function dv=showDecisionVariables(this)
            dv=this.optimizationEngine.evaluationService.problemPrototype.dv;
            for dIndex=1:numel(dv)
                fprintf('DV(%i) : ',dIndex);
                show(dv(dIndex));
            end
        end

        function sc=getStoppingCriteria(this)

            sc=DataTypeOptimization.ProgressTracking.getStoppingCriteria(this.progressTracer);

        end

        function isLoaded=isEngineLoaded(this)
            isLoaded=~isempty(this.optimizationEngine);
        end

        function setSolutions(this)



            switch this.finalState.solutionOutcome
            case DataTypeOptimization.SolutionOutcome.FeasibleSolutionFound


                solutions=this.getAllFeasibleSolutions();
            case DataTypeOptimization.SolutionOutcome.NoFeasibleSolutionFound


                solutions=this.getAllValidSolutions();

                solutions=this.sortByMaxDifference(solutions);
            otherwise

                solutions=this.getAllSolutions();
            end

            this.Solutions=solutions;
        end

        function setFinalOutcome(this)

            outcome=DataTypeOptimization.SolutionOutcome.getString(this.finalState.solutionOutcome);


            this.FinalOutcome=outcome;
        end

        function runID=getBaselineRunID(this,scenarioIndex)
            runID=this.baselineRunID(scenarioIndex);
            if~Simulink.sdi.isValidRunID(runID)
                runID=Simulink.sdi.createRun(this.baselineSimOut(scenarioIndex).SimulationMetadata.UserString,...
                'vars',this.baselineSimOut(scenarioIndex));
                this.baselineRunID(scenarioIndex)=runID;
                comparisonUtility=DataTypeOptimization.SDIBaselineComparison();



                comparisonUtility.bindConstraints(runID,this.OptimizationOptions.Constraints.values);
            end
        end

        function exploreSolution(this,solution,scenarioIndex,keepOriginalModelParameters)
            try

                this.applySolution(solution,scenarioIndex,keepOriginalModelParameters);


                open_system(this.Model);


                set_param(this.Model,'SimulationCommand','update');


                showComparisonView(this,solution,scenarioIndex);

            catch errDiagnostic %#ok<NASGU>

            end

        end

        function showComparisonView(this,solution,scenarioIndex)


            if solution.hasLoggedSignals(scenarioIndex)
                fxptui.Plotter.compareRuns(...
                this.getBaselineRunID(scenarioIndex),...
                solution.RunID(scenarioIndex),1);
            end

        end

        function revertSolution(this)
            coder.internal.MLFcnBlock.FPTSupport.overrideConvertedMATLABFunctionBlocks(...
            this.Model,...
            coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingOriginal);

            this.modelState.revert();

            sfObj=Simulink.SimulationInput(this.Model);
            sfObj.Variables=this.sfEntries;
            sfObj.applyToModel();
        end

        function applySolution(this,solution,scenarioIndex,keepOriginalModelParameters)



            if~isempty(this.modelState)
                this.modelState.revert();
            end


            if this.isEngineLoaded()
                this.modelState=DataTypeOptimization.Application.ApplyUtil.applySolution(...
                this.optimizationEngine.evaluationService.environmentProxy,...
                this.optimizationEngine.evaluationService.problemPrototype,...
                solution,...
                scenarioIndex,...
                keepOriginalModelParameters);
            else
                this.modelState=DataTypeOptimization.Application.ApplyUtil.applySolution([],[],solution,scenarioIndex,keepOriginalModelParameters);
            end
        end

        function prepareToExport(this)


            setFinalOutcome(this);


            setSolutions(this);

            switch this.finalState.solutionOutcome
            case{DataTypeOptimization.SolutionOutcome.FeasibleSolutionFound,...
                DataTypeOptimization.SolutionOutcome.NoFeasibleSolutionFound}



                this.applySolution(this.Solutions(1),1,false);


                this.calculateFailureRateStatistics();

            case DataTypeOptimization.SolutionOutcome.NoValidSolutionFound

                revert(this);
            end

        end

        function calculateFailureRateStatistics(this)

            scenarios=this.OptimizationOptions.AdvancedOptions.SimulationScenarios;
            numScenarios=numel(scenarios);
            if numScenarios>0

                allSolutions=this.getAllValidSolutions();
                numSolutions=numel(allSolutions);
                if numSolutions>0


                    scNumPass=zeros(numScenarios,1);
                    scNumEval=zeros(numScenarios,1);

                    for sIndex=1:numSolutions
                        for scIndex=1:numel(allSolutions(sIndex).simOut)
                            scNumPass(scIndex)=scNumPass(scIndex)+allSolutions(sIndex).simOut(scIndex).pass;
                            scNumEval(scIndex)=scNumEval(scIndex)+1;
                        end
                    end


                    failureRateArray=zeros(numScenarios,3);
                    failureRateArray(:,1)=100*scNumPass./scNumEval;
                    failureRateArray(:,2)=scNumPass;
                    failureRateArray(:,3)=scNumEval;

                    this.failureRateTable=array2table(failureRateArray,...
                    'VariableNames',{'Pass_Percent','Pass_Num','Evaluation_Num'},...
                    'RowNames',arrayfun(@(x)(sprintf('Scenario %i',x)),1:numScenarios,'UniformOutput',false));

                end
            end
        end

        function registerResultState(this)

            resultAnalyser=DataTypeOptimization.OptimizationResultAnalyzer(this);
            this.finalState=resultAnalyser.analyze();
        end

        function allFeasible=getAllFeasibleSolutions(this)

            allSolutions=this.getAllValidSolutions();
            feasibleIndex=arrayfun(@(x)(x.Pass),allSolutions);
            allFeasible=allSolutions(feasibleIndex);

            allFeasible=this.sortByCost(allFeasible);
        end

        function allSolutions=sortByCost(~,allSolutions)

            costVec=arrayfun(@(x)(x.Cost),allSolutions);
            [~,cIndex]=sort(costVec);
            allSolutions=allSolutions(cIndex);
        end

        function allSolutions=sortByMaxDifference(~,allSolutions)

            diffVec=arrayfun(@(x)(x.MaxDifference),allSolutions);
            [~,dIndex]=sort(diffVec);
            allSolutions=allSolutions(dIndex);

        end

        function allSolutions=sortByIndex(this,allSolutions)
            metaData=this.solutionsRepository.solutionMetaData;
            sortedSolutions=DataTypeOptimization.OptimizationSolution.empty(0,length(allSolutions));

            for sIndex=1:length(allSolutions)
                md=metaData(allSolutions(sIndex).id);
                sortedSolutions(md.index)=allSolutions(sIndex);
            end
        end

        function[allFeasibleSorted,allInfeasibleSorted]=getAllSolutionsSorted(this)
            allValid=this.getAllValidSolutions();
            allFeasibleSorted=this.getAllFeasibleSolutions();
            allInfeasibleSorted=sortByMaxDifference(this,setdiff(allValid,allFeasibleSorted));

        end
    end

end


