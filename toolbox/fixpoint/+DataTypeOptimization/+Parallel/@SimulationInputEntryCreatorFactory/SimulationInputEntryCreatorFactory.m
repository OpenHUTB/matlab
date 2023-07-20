classdef SimulationInputEntryCreatorFactory<handle







    properties(SetAccess=private)
strategiesFactory
    end

    methods
        function this=SimulationInputEntryCreatorFactory()

            this.strategiesFactory=DataTypeOptimization.Parallel.DataTypeMapping.MappingStrategiesFactory();

        end

        function siCreator=getCreator(this,pvPair)

            strategies=cell(size(pvPair,1),1);

            for pIndex=1:size(pvPair,1)
                currentPair=pvPair{pIndex};

                strategies{pIndex}=this.strategiesFactory.getStrategy(currentPair);

            end


            siCreator=DataTypeOptimization.Parallel.SimulationInputEntryCreator(strategies);

        end
    end

end


