classdef DesignAnalyzer<handle






    properties(SetAccess=private)
        Design(1,:)char
ModelsUnderSUDandAssociatedResultsMap
    end

    properties(Hidden,Access=private)
        DesignAnalyzerResult designcostestimation.internal.costestimate.OperatorCountEstimate
    end

    properties(Hidden,Access=private)
        LifetimeService designcostestimation.internal.services.LifetimeManagement;
    end

    methods

        function obj=DesignAnalyzer(design)
            obj.Design=design;
            obj.ModelsUnderSUDandAssociatedResultsMap=containers.Map;
            currentModelAnalysisObj=designcostestimation.internal.AnalysisResult(obj.Design);
            obj.ModelsUnderSUDandAssociatedResultsMap(obj.Design)=currentModelAnalysisObj;
            obj.DesignAnalyzerResult=designcostestimation.internal.costestimate.OperatorCountEstimate(obj.Design);
        end



        function DesignAnalyzerResult=Analyze(obj,DesignAnalyzerConfiguration)
            obj.LifetimeService=designcostestimation.internal.services.LifetimeManagement(obj.Design);
            obj.preProcess();
            runCostEstimation(obj,DesignAnalyzerConfiguration);
            DesignAnalyzerResult=obj.DesignAnalyzerResult;
            obj.LifetimeService.restoreDesigns();
        end

    end

    methods(Hidden)

        function preProcess(obj)
            Preprocessor=designcostestimation.internal.preprocessing.PreprocessingService(obj.Design);
            Preprocessor.process();
        end


        function totalCostOfDesign=runCostEstimation(obj,DesignAnalyzerConfiguration)

            obj.getStrategyAndRunAnalysisIfRequired(DesignAnalyzerConfiguration);


            obj.generateCost(DesignAnalyzerConfiguration);


            totalCostOfDesign=obj.DesignAnalyzerResult.TotalCost;
        end

        function getStrategyAndRunAnalysisIfRequired(obj,DesignAnalyzerConfiguration)



            if(DesignAnalyzerConfiguration.RunMode==designcostestimation.internal.DesignAnalyzerRunMode.RunAnalysisAndCostEstimation||...
                DesignAnalyzerConfiguration.RunMode==designcostestimation.internal.DesignAnalyzerRunMode.RunAnalysisOnly)


                AnalysisObj=designcostestimation.internal.GetAnalysisStrategyFactory.getAnalysisStrategy(DesignAnalyzerConfiguration.AnalysisOptions);


                obj.runAnalysis(AnalysisObj);

            end
        end


        function runAnalysis(obj,Analysis)
            StrategyExecuter=designcostestimation.internal.RunStrategy(obj.ModelsUnderSUDandAssociatedResultsMap);
            StrategyExecuter.executeStrategy(Analysis);
        end


        function generateCost(obj,DesignAnalyzerConfiguration)

            activeConfigSet=getActiveConfigSet(obj.Design);

            costConfig=designcostestimation.internal.CostEstimatorConfiguration(activeConfigSet);

            obj.setCostConfigOperatorWeight(costConfig,DesignAnalyzerConfiguration);

            costConfig.EnableDiagnostics=DesignAnalyzerConfiguration.EnableDiagnostics;

            aCostEstimator=designcostestimation.internal.CostEstimator(obj.ModelsUnderSUDandAssociatedResultsMap,costConfig);

            aCostEstimator.generateCost();

            obj.calculateCostOfSUD();
        end


        function calculateCostOfSUD(obj)

            currentResult=obj.getAnalysisResult();

            CostGraph=designcostestimation.internal.graphutil.CostGraph(obj.Design);

            CostGraph.addCostEstimates(currentResult);

            obj.DesignAnalyzerResult.setCostGraph(CostGraph);
            if(~isempty(currentResult.OpCount))

                T=cell2table(currentResult.OpCount,'VariableNames',{'BlockName','Counts','Operator','Data Type'});
                obj.DesignAnalyzerResult.SetRawCostInformation(T);
            end

            obj.DesignAnalyzerResult.setDiagnostics(currentResult.Diagnostics);
        end

        function currentResult=getAnalysisResult(obj)
            currentResult=obj.ModelsUnderSUDandAssociatedResultsMap(obj.Design);
        end

    end

    methods(Static,Hidden)


        function setCostConfigOperatorWeight(costConfig,aDesignAnalyzerConfiguration)
            if(aDesignAnalyzerConfiguration.UseCustomWeights)
                costConfig.setOperatorWeight(aDesignAnalyzerConfiguration.OperatorWeights);
            end
        end
    end
end


