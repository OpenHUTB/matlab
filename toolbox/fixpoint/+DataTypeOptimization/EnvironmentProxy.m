classdef EnvironmentProxy<handle

    properties(Hidden)
mlfbMaps
rangeExtractionInterface
context
    end

    properties(Constant,Hidden)
        constModelParameters={...
        'SignalLogging','on',...
        'ReturnWorkspaceOutputs','on',...
        'SaveFormat','Dataset',...
        'ShowPortDataTypes','on',...
        'SignalRangeChecking','error',...
        'ParameterDowncastMsg','none',...
        'ParameterUnderflowMsg','none',...
        'ParameterPrecisionLossMsg','none',...
        'ParameterOverflowMsg','none',...
        'FixptConstPrecisionLossMsg','none',...
        'FixptConstOverflowMsg','none',...
        'FixptConstUnderflowMsg','none',...
        'IntegerOverflowMsg','none',...
        'IntegerSaturationMsg','none',...
        'SaveTime','off',...
        'SaveOutput','off'...
        };
    end

    methods
        function this=EnvironmentProxy(model,sud)

            this.context=DataTypeOptimization.EnvironmentContext(model,sud);


            this.rangeExtractionInterface=fxptds.RangeAggregation.getRangeExtractionInterface();


            this.mlfbMaps.model2MLFB=containers.Map();
            this.mlfbMaps.mlfb2mlv=containers.Map();
        end

        function simOut=instrumentScenarios(this,scenarios,elementsToInstrument)




            if nargin<3
                elementsToInstrument=this.context.AllModels;
            end
            oldSettings=cellfun(@(x)(get_param(x,'MinMaxOverflowLogging')),elementsToInstrument,'UniformOutput',false);
            cellfun(@(x)(set_param(x,'MinMaxOverflowLogging','MinMaxAndOverflow')),elementsToInstrument);

            sInit=Simulink.SimulationInput(this.context.TopModel);
            sInit=sInit.setModelParameter(...
            'SimulationMode','normal',...
            'FPTRunName',DataTypeOptimization.BaselineProperties.RunName,...
            'MinMaxOverflowArchiveMode','Merge');
            sInit=sInit.setModelParameter(...
            this.constModelParameters{:});

            merger=DataTypeOptimization.SimulationInput.SimulationInputMerger(DataTypeOptimization.SimulationInput.ConflictResolutionSpecification);


            for sIndex=1:length(scenarios)
                scenarios(sIndex)=merger.merge(scenarios(sIndex),sInit);
            end

            warning('off','Simulink:Commands:SimulationsWithErrors')
            simOut=sim(scenarios,'ShowSimulationManager','off','ShowProgress','off');
            warning('on','Simulink:Commands:SimulationsWithErrors')


            for sIndex=1:length(simOut)
                if~isempty(simOut(sIndex).ErrorMessage)
                    diagnostic=simOut(sIndex).SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic;
                    if~isempty(diagnostic)

                        diagnostic.reportAsError;
                    end
                end
            end


            cellfun(@(x,y)(set_param(x,'MinMaxOverflowLogging',y)),elementsToInstrument,oldSettings);


            this.getMLFBMaps();


            SimulinkFixedPoint.ApplicationData.mergeModelReferenceData(get_param(this.context.TopModel,'Object'),DataTypeOptimization.BaselineProperties.RunName);
        end

        function deriveRanges(this)

            converter=DataTypeWorkflow.Converter(this.context.SUD,'TopModel',this.context.TopModel);
            converter.CurrentRunName=DataTypeOptimization.BaselineProperties.RunName;
            converter.deriveMinMax();
        end

        function[allGroups,groupRanges,filteredGroups]=getDataTypeGroups(this,hardwareConstraint,simIn)
            this.setFPTRunName(DataTypeOptimization.BaselineProperties.RunName);


            settingStruct=SimulinkFixedPoint.AutoscalerProposalSettings;
            settingStruct.scaleUsingRunName=DataTypeOptimization.BaselineProperties.RunName;


            engineContext=SimulinkFixedPoint.DataTypingServices.EngineContext(...
            this.context.TopModel,...
            this.context.SUD,...
            settingStruct,...
            SimulinkFixedPoint.DataTypingServices.EngineActions.Collect,...
            simIn);
            engineInterface=SimulinkFixedPoint.DataTypingServices.EngineInterface.getInterface();
            engineInterface.run(engineContext);


            applicationData=SimulinkFixedPoint.getApplicationData(this.context.TopModel);
            runObj=applicationData.dataset.getRun(DataTypeOptimization.BaselineProperties.RunName);

            allGroups={};
            if~isempty(runObj.dataTypeGroupInterface.nodes)

                results=runObj.dataTypeGroupInterface.nodes.values;


                resultsScope=SimulinkFixedPoint.AutoscalerUtils.getResultsScopeMap(results,this.context.SUD);

                allGroups=runObj.dataTypeGroupInterface.getGroups();
            end


            inSUD=false(1,numel(allGroups));
            for gIndex=1:numel(allGroups)
                members=allGroups{gIndex}.getGroupMembers;
                for mIndex=1:numel(members)
                    if resultsScope(members{mIndex}.UniqueIdentifier.UniqueKey)
                        inSUD(gIndex)=true;
                        break;
                    end
                end
            end
            filteredGroups=allGroups(~inSUD);
            allGroups(~inSUD)='';


            optProposableCheck=SimulinkFixedPoint.DataTypingServices.GroupProposalCheck.OptimizationStrategy();

            isProposable=false(numel(allGroups),1);
            groupRanges=cell(size(allGroups));
            for gIndex=1:numel(allGroups)
                groupRanges{gIndex}=this.rangeExtractionInterface.getRanges(allGroups{gIndex});
                isProposable(gIndex)=optProposableCheck.isGroupProposable(...
                hardwareConstraint+allGroups{gIndex}.constraints,...
                allGroups{gIndex}.getSpecifiedDataType(settingStruct),...
                groupRanges{gIndex},...
                allGroups{gIndex});
            end
            filteredGroups=[filteredGroups,allGroups(~isProposable)];
            allGroups(~isProposable)='';
            groupRanges(~isProposable)='';


            proposableGroupIDs=cellfun(@(x)(x.id),allGroups);
            MLFBs=this.mlfbMaps.mlfb2mlv.keys;
            for bIndex=1:numel(MLFBs)
                mlv=this.mlfbMaps.mlfb2mlv(MLFBs{bIndex});
                mlvGroups=cellfun(@(x)(runObj.dataTypeGroupInterface.getGroupForResult(x)),mlv,'UniformOutput',false);
                mlvGroupIDs=cellfun(@(x)(x.id),mlvGroups);
                mlv(~arrayfun(@(x)(any(proposableGroupIDs==x)),mlvGroupIDs))='';
                this.mlfbMaps.mlfb2mlv(MLFBs{bIndex})=mlv;

            end
        end

    end
    methods(Hidden)

        function getMLFBMaps(this)
            this.mlfbMaps.model2MLFB=containers.Map();
            this.mlfbMaps.mlfb2mlv=containers.Map();
            for mIndex=1:numel(this.context.AllModels)
                appData=SimulinkFixedPoint.getApplicationData(this.context.AllModels{mIndex});
                runObj=appData.dataset.getRun(DataTypeOptimization.BaselineProperties.RunName);
                allResults=runObj.getResultsAsCellArray();

                mlvIndex=cellfun(@(x)(isa(x,'fxptds.MATLABVariableResult')),allResults);
                if any(mlvIndex)
                    mlvResults=allResults(mlvIndex);

                    allMLFB=cellfun(@(x)(x.UniqueIdentifier.MATLABFunctionIdentifier.SID),mlvResults,'UniformOutput',false);
                    uniqueMLFB=unique(allMLFB);
                    this.mlfbMaps.model2MLFB(this.context.AllModels{mIndex})=uniqueMLFB;

                    for bIndex=1:numel(uniqueMLFB)
                        mlv2blockIndex=strcmp(allMLFB,uniqueMLFB{bIndex});
                        if any(mlv2blockIndex)
                            this.mlfbMaps.mlfb2mlv([this.context.AllModels{mIndex},':::',uniqueMLFB{bIndex}])=mlvResults(mlv2blockIndex);
                        end
                    end
                end
            end
        end

        function setFPTRunName(this,runName)

            for mIndex=1:numel(this.context.AllModels)
                appData=SimulinkFixedPoint.getApplicationData(this.context.AllModels{mIndex});


                appData.ScaleUsing=runName;
            end
        end
    end
end

