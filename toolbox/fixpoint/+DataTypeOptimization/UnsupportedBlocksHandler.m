classdef UnsupportedBlocksHandler<handle




    properties(SetAccess=private,Transient=true)
Context

    end

    properties(SetAccess=private,Transient=true,Hidden)
AnalyzerScope
CapabilityManager
UnsupportedConstructs
DecoupledConstructs

    end

    methods
        function this=UnsupportedBlocksHandler(model,sud)
            this.Context=DataTypeOptimization.EnvironmentContext(model,sud);
            this.CapabilityManager=DataTypeWorkflow.Advisor.CapabilityManager();
            this.UnsupportedConstructs=[];
            this.DecoupledConstructs=[];
            this.setupScope();

        end

        function unsupportedExist=checkUnsupported(this)
            this.UnsupportedConstructs=this.CapabilityManager.getUnsupportedConstruct(this.AnalyzerScope);
            unsupportedExist=~isempty(this.UnsupportedConstructs);

        end

        function decoupledConstructs=handleUnsupported(this,options)
            decoupledConstructs={};

            switch options.AdvancedOptions.HandleUnsupported
            case DataTypeOptimization.UnsupportedHandlingMode.Warn
                MSLDiagnostic('SimulinkFixedPoint:dataTypeOptimization:unsupportedError').reportAsWarning;

            case DataTypeOptimization.UnsupportedHandlingMode.Error
                DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:unsupportedError');

            case DataTypeOptimization.UnsupportedHandlingMode.Isolate
                this.DecoupledConstructs=this.CapabilityManager.decoupleUnsupportedConstruct();
                decoupledConstructs=this.DecoupledConstructs;

            end

        end
    end

    methods(Hidden)
        function setupScope(this)
            this.AnalyzerScope=struct(...
            'TopModel',this.Context.TopModel,...
            'SelectedSystem',this.Context.SUD);
            this.AnalyzerScope.SelectedSystemsToScale=[this.Context.AllModelsUnderSUD{1:end-1},{this.Context.SUD}];




            appData=SimulinkFixedPoint.getApplicationData(this.Context.TopModel);
            appData.ScaleUsing=DataTypeOptimization.BaselineProperties.RunName;
            runObj=appData.dataset.getRun(appData.ScaleUsing);
            runObj.initialize(this.Context.TopModel);
        end

    end

end
