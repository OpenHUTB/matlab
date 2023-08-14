classdef CollectionSettings<handle




    properties(Constant,Hidden)
        BaselineRunName='BaselineRun';
        EmbeddedRunName='EmbeddedRun';
    end

    properties

        RangeCollectionMode(1,1)DataTypeWorkflow.RangeCollectionMode{mustBeMember(RangeCollectionMode,0:2)}


SimulationScenarios


ShortcutToApply


ProgressTrackingOptions


        ConstraintSettings DataTypeWorkflow.ConstraintSettings
    end

    properties(Hidden)
RunName
    end

    methods
        function this=CollectionSettings(varargin)

            fpdLicenseCheck();

            try
                this.initializeDefaultValues(varargin{:});
            catch ex
                throwAsCaller(ex);
            end

        end

        function set.ShortcutToApply(this,shortcutToApply)


            validShortcuts=[DataTypeWorkflow.ShortcutManager.DefaultFactoryNames,DataTypeWorkflow.ShortcutManager.CleanupShortcut];
            validatestring(shortcutToApply,validShortcuts);
            this.ShortcutToApply=shortcutToApply;

        end

        function set.SimulationScenarios(this,simulationScenarios)
            validateattributes(simulationScenarios,{'Simulink.SimulationInput'},{});
            validateSimulationInputArray(this,simulationScenarios);
            this.SimulationScenarios=simulationScenarios;
        end

        function set.ProgressTrackingOptions(this,valueStruct)
            if isstruct(valueStruct)

                if isfield(valueStruct,'ShowSimulationManager')
                    value=valueStruct.ShowSimulationManager;
                    validateProgressTracking(this,value);
                    this.ProgressTrackingOptions.ShowSimulationManager=valueStruct.ShowSimulationManager;
                end

                if isfield(valueStruct,'ShowProgress')
                    value=valueStruct.ShowProgress;
                    validateProgressTracking(this,value);
                    this.ProgressTrackingOptions.ShowProgress=valueStruct.ShowProgress;
                end

            end

        end

    end

    methods(Access=public,Hidden)
        function validateSimulationInputArray(~,scenarios)
            if~isempty(scenarios)
                modelNames=unique({scenarios.ModelName});


                if any(cellfun(@(x)(isempty(x)),modelNames))
                    DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:invalidScenariosEmptyModelName');
                end


                if numel(modelNames)>1
                    DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:invalidScenariosSingleTopModel');
                end
            end
        end

        function validateProgressTracking(this,value)
            validStrings=["on","off"];
            validatestring(value,validStrings);
            if strcmpi(value,"on")&&~this.hasSimulationScenarios
                DAStudio.error('SimulinkFixedPoint:autoscaling:invalidProgressTrackingValue');
            end
        end

        function initializeDefaultValues(this,varargin)
            p=this.createInputParser();
            p.parse(varargin{:});

            this.RangeCollectionMode=p.Results.RangeCollectionMode;
            this.SimulationScenarios=p.Results.SimulationScenarios;
            this.ShortcutToApply=p.Results.ShortcutToApply;

            this.ProgressTrackingOptions.ShowSimulationManager="off";
            this.ProgressTrackingOptions.ShowProgress="off";

            this.RunName=p.Results.RunName;

            this.ConstraintSettings=DataTypeWorkflow.ConstraintSettings;
        end

        function p=createInputParser(this)


            p=inputParser();
            p.KeepUnmatched=true;
            p.addParameter('RangeCollectionMode',DataTypeWorkflow.RangeCollectionMode.Simulation);
            p.addParameter('SimulationScenarios',Simulink.SimulationInput.empty);


            p.addParameter('ShortcutToApply',fxptui.message('lblOriginalSettings'));
            p.addParameter('RunName',this.BaselineRunName);
        end

        function b=hasSimulationScenarios(this)
            b=~isempty(this.SimulationScenarios);
        end
    end
end


