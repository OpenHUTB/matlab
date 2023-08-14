classdef MappingStrategiesFactory<handle












    methods
        function strategy=getStrategy(~,pvPair)
            strategyClass=pvPair{1};
            strategy={};
            switch strategyClass
            case 'FullDataTypeStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.FullDataTypeStrategy(pvPair{2},pvPair{3});
            case 'WordLengthStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.WordLengthStrategy(pvPair{2},pvPair{3});
            case 'FractionLengthStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.FractionLengthStrategy(pvPair{2},pvPair{3});
            case 'SignednessStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.SignednessStrategy(pvPair{2},pvPair{3});
            case 'AutoSignednessDataTypeStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.AutoSignednessDataTypeStrategy(pvPair{2},pvPair{3});
            case 'GenericPropertyStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.GenericPropertyStrategy(pvPair{2},pvPair{3},pvPair{4});
            case 'DataTypeObjectStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.DataTypeObjectStrategy(pvPair{2});
            case 'AliasTypeObjectStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.AliasTypeObjectStrategy(pvPair{2});
            case 'NumericTypeObjectStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.NumericTypeObjectStrategy(pvPair{2});
            case 'BreakPointObjectStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.BreakPointObjectStrategy(pvPair{2});
            case 'LUTObjectStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.LUTObjectStrategy(pvPair{2},pvPair{3},pvPair{4});
            case 'BusObjectStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.BusObjectStrategy(pvPair{2},pvPair{3});
            case 'StateflowStrategy'
                strategy=DataTypeOptimization.Parallel.DataTypeMapping.StateflowStrategy(pvPair{2});
            end
        end
    end

end

