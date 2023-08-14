classdef SimulationInputCreator<handle







    properties
strategies
models
options
baselineSimOut
scenarioMerger
prepSimIn
    end

    methods
        function this=SimulationInputCreator(strategies,models,options,baselineSimOut,prepSimIn)

            this.strategies=strategies;
            this.models=models;
            this.options=options;
            this.baselineSimOut=baselineSimOut;
            this.scenarioMerger=DataTypeOptimization.SimulationInput.SimulationInputMerger(DataTypeOptimization.SimulationInput.ConflictResolutionSpecification);
            this.prepSimIn=prepSimIn;
        end

        function getSimulationInput(this,problemPrototype,solution)





            simulationInputInitial=this.getInitialSimulationInput(solution.id);


            specificationsInput=this.getSpecificationsDelta(problemPrototype);
            initialWithSpecifications=this.scenarioMerger.merge(simulationInputInitial,specificationsInput);


            simulationInputDataTypes=getDataTypeDelta(this,problemPrototype,solution);


            systemDefinedChanges=this.scenarioMerger.merge(initialWithSpecifications,simulationInputDataTypes);


            simulationInputArray=Simulink.SimulationInput.empty(length(problemPrototype.simulationScenarios),0);

            for scIndex=1:length(problemPrototype.simulationScenarios)

                simulationInputArray(scIndex)=this.scenarioMerger.merge(systemDefinedChanges,problemPrototype.simulationScenarios(scIndex));

                objectiveFunction=[];
                if scIndex==1
                    objectiveFunction=problemPrototype.objectiveFunction;
                end


                simulationInputArray(scIndex)=this.setFunctions(...
                simulationInputArray(scIndex),...
                this.baselineSimOut(scIndex),...
                objectiveFunction,...
                solution);


                simulationInputArray(scIndex)=simulationInputArray(scIndex).setUserString([simulationInputArray(scIndex).UserString,sprintf('_%i',scIndex)]);
            end


            solution.simIn=simulationInputArray;
        end
    end

    methods(Hidden)
        function simulationInput=getSpecificationsDelta(this,problemPrototype)
            simulationInput=this.getEmptySimulationInput();


            for sIndex=1:numel(problemPrototype.specifications)

                groupID=problemPrototype.specifications(sIndex).Group.id;
                if this.strategies.isKey(groupID)
                    currentStrategies=this.strategies(groupID);

                    dtStr=problemPrototype.specifications(sIndex).getDataTypeStr();
                    dataType=SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer(dtStr,[]);



                    for stIndex=1:numel(currentStrategies)
                        simulationInput=currentStrategies{stIndex}.addEntry(simulationInput,dataType);
                    end
                end
            end
        end

        function simulationInput=getDataTypeDelta(this,problemPrototype,solution)
            simulationInput=this.getEmptySimulationInput();


            for dIndex=1:numel(problemPrototype.dv)

                groupID=problemPrototype.dv(dIndex).group.id;
                if this.strategies.isKey(groupID)
                    currentStrategies=this.strategies(groupID);

                    dataType=DataTypeOptimization.Application.ApplyUtil.getDataType(problemPrototype.dv(dIndex),solution.definitionDomainIndex(dIndex));



                    for sIndex=1:numel(currentStrategies)
                        simulationInput=currentStrategies{sIndex}.addEntry(simulationInput,dataType);
                    end
                end
            end
        end

        function simulationInput=getEmptySimulationInput(this)
            topModel=this.models{end};
            simulationInput=Simulink.SimulationInput(topModel);
        end

        function simulationInput=getInitialSimulationInput(this,runName)

            simulationInput=this.getEmptySimulationInput();


            simulationInput=this.setLogging(simulationInput);



            simulationInput=simulationInput.setModelParameter(...
            DataTypeOptimization.EnvironmentProxy.constModelParameters{:});






            simMode=DataTypeOptimization.SimMode.tostring(this.options.AdvancedOptions.EvaluationSimMode);
            simulationInput=simulationInput.setModelParameter('SimulationMode',simMode);





            simulationInput=simulationInput.setModelParameter('DataTypeOverride','off');





            simulationInput=simulationInput.setModelParameter('MinMaxOverflowLogging','ForceOff');



            simulationInput.UserString=runName;


            simulationInput=this.scenarioMerger.merge(simulationInput,this.prepSimIn);

        end

        function simulationInput=setFunctions(this,simulationInput,bSimOut,objectiveFunction,solution)

            parsimOptions=this.options;
            parsimBaselineSimOut=bSimOut;
            postSimFcn=simulationInput.PostSimFcn;
            parsimObjectiveFunction=objectiveFunction;
            parsimSolution=solution;
            simulationInput.PostSimFcn=@(x)(DataTypeOptimization.Parallel.postSimFxpOpt(x,...
            parsimObjectiveFunction,...
            parsimSolution,...
            parsimBaselineSimOut,...
            parsimOptions,...
            postSimFcn));
        end

        function simulationInput=setLogging(this,simulationInput)
            simulationInput=DataTypeOptimization.Parallel.Utils.setLogging(simulationInput,this.options);
        end
    end
end

