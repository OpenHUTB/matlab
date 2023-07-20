


classdef RateTransitionBlock<slci.simulink.Block

    methods

        function obj=RateTransitionBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'Integrity','on'));
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'Deterministic','on'));
            obj.addConstraint(...
            slci.compatibility.InitialConditionsConstraint('InitialCondition'));
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('InitialCondition'));

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);

        end

    end

end
