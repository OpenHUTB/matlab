classdef ModelingService<handle

    properties(SetAccess=private)
environmentProxy
hardwareConstraint
    end

    properties(SetAccess=private,Hidden)
        instrumentationOriginalValue=-1;
    end

    methods
        function this=ModelingService(environmentProxy)
            this.environmentProxy=environmentProxy;
            this.hardwareConstraint=SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraintFactory.getConstraint(this.environmentProxy.context.TopModel);
        end


        function dv=getDecisionVariables(this,options,allGroups,groupRange)

            if~isempty(allGroups)

                dv=DataTypeOptimization.DecisionVariable.empty;
                for gIndex=1:numel(allGroups)

                    dv(gIndex)=DataTypeOptimization.DecisionVariable(...
                    DataTypeOptimization.DefinitionDomain(...
                    groupRange{gIndex},...
                    allGroups{gIndex}.constraints+this.hardwareConstraint,options.AdvancedOptions.SafetyMargin),...
                    allGroups{gIndex});
                end

            else

                DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:unableToModel');
            end
        end

        function globalWLConstraints=getWordLengthDomain(this,opt)



            allowableWLConstraint=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint([],opt.AllowableWordLengths,[]);
            this.hardwareConstraint=this.hardwareConstraint+allowableWLConstraint;
            if this.hardwareConstraint.HasWordlengthConflict


                DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:emptyWordLengthDomain');
            end

            globalWLConstraints=this.hardwareConstraint.SpecificWL;

        end

        function applyConstraints(this,opt)

            tolerancesUtil=DataTypeOptimization.Constraints.ApplyTolerancesUtil();


            tolerancesUtil.applyTol(this.environmentProxy.context.AllModels,opt);
        end

        function[problemPrototype,baselineSimOut,baselineRunID]=modelProblem(this,options)
            problemPrototype=DataTypeOptimization.ProblemPrototype();


            activateSpecifications(this,options);




            this.applyConstraints(options);


            [baselineSimOut,baselineRunID,scenarios]=collectRanges(this,options);


            problemPrototype.gddm=this.getWordLengthDomain(options);


            [activeGroups,groupRanges,inactiveGroups]=...
            this.environmentProxy.getDataTypeGroups(this.hardwareConstraint,options.AdvancedOptions.SimulationScenarios);


            [activeGroups,groupRanges,inactiveGroups]=...
            this.applySpecifications(activeGroups,groupRanges,inactiveGroups,options);


            allSpecifications=options.Specifications.values();
            problemPrototype.specifications=[allSpecifications{:}];


            problemPrototype.dv=this.getDecisionVariables(options,activeGroups,groupRanges);


            problemPrototype.groupConnectivityGraph=fxptds.getGroupConnectivityGraph(activeGroups,this.environmentProxy.context.TopModel);


            if options.AdvancedOptions.PerformSlopeBiasCancellation
                compileHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(this.environmentProxy.context.TopModel);
                compileHandler.start();
                cleanupObj=onCleanup(@()compileHandler.stop());
                [constraints,constraintVariables]=cpopt.internal.createGroupConstraints(...
                this.environmentProxy.context.TopModel,activeGroups,inactiveGroups,options.Specifications.values,...
                cpopt.internal.GroupConstraintFactory());
                problemPrototype.slopeBiasConstraints=constraints;
                problemPrototype.constraintVariables=constraintVariables;
                compileHandler.stop();
            end


            problemPrototype.constFunc=options.Constraints.values;


            problemPrototype.simulationScenarios=scenarios;


            problemPrototype.objectiveFunction=...
            DataTypeOptimization.Objectives.ObjectiveFactory.getObjective(...
            options,...
            this.environmentProxy.context,...
            problemPrototype.dv);

        end

        function activateSpecifications(this,options)

            allSpecifications=options.Specifications.values();
            allSpecifications=[allSpecifications{:}];

            for sIndex=1:numel(allSpecifications)
                allSpecifications(sIndex).setUniqueID('Model',this.environmentProxy.context.TopModel);
            end
        end

        function[activeGroups,groupRanges,inactiveGroups]=applySpecifications(~,activeGroups,groupRanges,inactiveGroups,opt)

            allSpecifications=opt.Specifications.values();
            allSpecifications=[allSpecifications{:}];

            activeGroupIDs=zeros(1,numel(activeGroups));
            for gIndex=1:numel(activeGroups)
                activeGroupIDs(gIndex)=activeGroups{gIndex}.id;
            end
            allGroups=[activeGroups,inactiveGroups];


            key2gID=fxptds.Utils.uniqueKeyToGroupID(allGroups);
            gID2Indx=fxptds.Utils.groupIDToGroupIndex(allGroups);
            group2Spec=containers.Map('KeyType','double','ValueType','any');
            for sIndex=1:numel(allSpecifications)
                gID=key2gID(allSpecifications(sIndex).UniqueID.UniqueKey);
                groupIndex=gID2Indx(gID);
                allSpecifications(sIndex).setGroup(allGroups{groupIndex});
                if group2Spec.isKey(gID)
                    group2Spec(gID)=[group2Spec(gID),allSpecifications(sIndex)];
                else
                    group2Spec(gID)=allSpecifications(sIndex);
                end

            end

            sgID=group2Spec.keys;
            toFilterGroupIndex=[];
            for sIndex=1:numel(sgID)
                currentGroupID=sgID{sIndex};
                currentSpecs=group2Spec(currentGroupID);
                if numel(currentSpecs)>1
                    for ii=1:numel(currentSpecs)-1
                        for jj=ii+1:numel(currentSpecs)
                            if~DataTypeOptimization.Specifications.SpecificationsUtilities.areEquivalentDataTypes(...
                                currentSpecs(ii).Element.Value,...
                                currentSpecs(jj).Element.Value)
                                DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:specificationsConflicting',...
                                currentSpecs(ii).toString,...
                                currentSpecs(jj).toString);
                            end
                        end
                    end
                end


                if ismember(currentGroupID,activeGroupIDs)
                    gIndex=gID2Indx(currentGroupID);
                    toFilterGroupIndex=[toFilterGroupIndex,gIndex];%#ok<AGROW>
                end
            end

            if~isempty(toFilterGroupIndex)
                inactiveGroups=[inactiveGroups,activeGroups(toFilterGroupIndex)];
                activeGroups(toFilterGroupIndex)='';
                groupRanges(toFilterGroupIndex)='';
            end
        end

        function[baselineSimOut,baselineRunID,scenarios]=collectRanges(this,opt)
            if opt.AdvancedOptions.UseDerivedRangeAnalysis





                Simulink.FixedPointAutoscaler.sanityCheck(this.environmentProxy.context.SUD);

            end

            elementsToInstrument=this.environmentProxy.context.AllModels;
            if~isempty(opt.AdvancedOptions.InstrumentationContext)
                blockPath=Simulink.BlockPath(opt.AdvancedOptions.InstrumentationContext);
                blockPath.validate();
                blockPathStr=blockPath.convertToCell{1};
                instrumentationContext=DataTypeOptimization.EnvironmentContext(this.environmentProxy.context.TopModel,blockPathStr);
                elementsToInstrument=instrumentationContext.AllModelsUnderSUD;
            end

            scenarios=opt.AdvancedOptions.SimulationScenarios;
            if isempty(scenarios)
                scenarios=Simulink.SimulationInput(this.environmentProxy.context.TopModel);
            end

            if isequal(opt.ObservedPrecisionReduction,DataTypeOptimization.ObservedPrecisionLevel.Enhanced)
                this.instrumentationOriginalValue=slfeature('ObservedPrecision');
                slfeature('ObservedPrecision',1);
            end

            for sIndex=1:numel(scenarios)
                scenarios(sIndex)=DataTypeOptimization.Parallel.Utils.setLogging(scenarios(sIndex),opt);
            end


            mp=Simulink.Simulation.ModelParameter('DataTypeOverride',char(opt.AdvancedOptions.DataTypeOverride));
            mra=DataTypeOptimization.SimulationInput.ModelRefParameterApplicator(this.environmentProxy.context,mp);
            mra.applyParameters();

            beforeRunIDs=Simulink.sdi.getAllRunIDs();
            baselineSimOut=this.environmentProxy.instrumentScenarios(scenarios,elementsToInstrument);
            afterRunIDs=Simulink.sdi.getAllRunIDs();
            baselineRunID=setxor(afterRunIDs,beforeRunIDs);
            if length(baselineRunID)>1

                newRuns=arrayfun(@(x)(Simulink.sdi.getRun(x)),baselineRunID);
                [~,dateCreatedIndex]=sort(datenum([newRuns.DateCreated]));
                baselineRunID=baselineRunID(dateCreatedIndex);
            end

            restoreInstumentationFeatureValue(this);


            if opt.AdvancedOptions.UseDerivedRangeAnalysis
                this.environmentProxy.deriveRanges();
            end

            mra.revertParameters();

        end

        function delete(this)
            restoreInstumentationFeatureValue(this)
        end

        function restoreInstumentationFeatureValue(this)
            if this.instrumentationOriginalValue>=0
                slfeature('ObservedPrecision',this.instrumentationOriginalValue);
            end
        end
    end
end


