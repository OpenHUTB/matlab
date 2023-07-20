classdef UnitDelayBlock<slci.simulink.Block



    methods

        function obj=UnitDelayBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('InitialCondition'));
            obj.addConstraint(...
            slci.compatibility.InitialConditionsConstraint('InitialCondition'));
            obj.addConstraint(...
            slci.compatibility.BlockStateStorageClassConstraint('StateName'));
            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            false,'InputProcessing','Columns as channels (frame based)'));

            obj.addConstraint(...
            slci.compatibility.UnitDelayAsRateTransitionConstraint);

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


