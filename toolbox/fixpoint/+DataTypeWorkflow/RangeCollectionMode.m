classdef RangeCollectionMode<uint8




    enumeration
        Simulation(0)
        Derived(1)
        SimulationAndDerive(2)
    end

    methods(Hidden)
        function b=isSimulation(this)
            b=this==0||this==2;
        end

        function b=isDerived(this)
            b=this==1||this==2;
        end

    end

    methods(Static,Hidden)
        function value=clientKeywordToEnum(keyword)
            switch keyword
            case fxptui.message('simRangesValue')
                value=DataTypeWorkflow.RangeCollectionMode.Simulation;
            case fxptui.message('deriveRangesValue')
                value=DataTypeWorkflow.RangeCollectionMode.Derived;
            case fxptui.message('simDeriveRangesValue')
                value=DataTypeWorkflow.RangeCollectionMode.SimulationAndDerive;
            end
        end

        function value=enumToClientKeyword(enum)
            switch enum
            case DataTypeWorkflow.RangeCollectionMode.Simulation
                value=fxptui.message('simRangesValue');
            case DataTypeWorkflow.RangeCollectionMode.Derived
                value=fxptui.message('deriveRangesValue');
            case DataTypeWorkflow.RangeCollectionMode.SimulationAndDerive
                value=fxptui.message('simDeriveRangesValue');
            end
        end

    end
end



