classdef SimulationInputEntryCreator<handle











    properties(SetAccess=private)
mappingStrategies
    end

    methods
        function this=SimulationInputEntryCreator(mappingStrategies)
            this.mappingStrategies=mappingStrategies;
        end

        function simulationInput=addEntry(this,simulationInput,dataType)

            for sIndex=1:numel(this.mappingStrategies)
                simulationInput=this.mappingStrategies{sIndex}.addEntry(simulationInput,dataType);
            end
        end
    end

    methods(Static)
        function[strategiesMap,sfEntries]=getSimulationInputEntriesMap(problemPrototype)



            msf=DataTypeOptimization.Parallel.DataTypeMapping.MappingStrategiesFactory();




            strategiesMap=containers.Map('KeyType','double','ValueType','any');


            definitionDomainIndex=1;
            allGroups=cell(numel(problemPrototype.dv)+numel(problemPrototype.specifications),1);
            dataTypesStr=cell(numel(problemPrototype.dv)+numel(problemPrototype.specifications),1);
            for gIndex=1:numel(problemPrototype.dv)
                allGroups{gIndex}=problemPrototype.dv(gIndex).group;
                dataTypesStr{gIndex}=DataTypeOptimization.Application.ApplyUtil.getDataType(problemPrototype.dv(gIndex),definitionDomainIndex).evaluatedDTString;
            end


            for sIndex=1:numel(problemPrototype.specifications)
                allGroups{sIndex+numel(problemPrototype.dv)}=problemPrototype.specifications(sIndex).Group;
                dataTypesStr{sIndex+numel(problemPrototype.dv)}=problemPrototype.specifications(sIndex).Element.Value;
            end

            sfEntries=Simulink.Simulation.Variable.empty(1,0);

            for gIndex=1:numel(allGroups)
                [pv,tempSFEntries]=DataTypeOptimization.Application.ApplyUtil.applyGroup(allGroups{gIndex},dataTypesStr{gIndex});
                if~isempty(tempSFEntries)
                    sfEntries=[sfEntries;tempSFEntries];%#ok<AGROW>
                end
                siEntries=cell(numel(size(pv,1)),1);
                for pIndex=1:size(pv,1)
                    currentPair=pv{pIndex};
                    siEntries{pIndex,1}=msf.getStrategy(currentPair);
                end
                if~isempty(pIndex)
                    strategiesMap(allGroups{gIndex}.id)=siEntries;
                end
            end

        end
    end

end
