

classdef SignalSpecificationBlock<slci.simulink.Block

    methods

        function obj=SignalSpecificationBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            true,'VarSizeSig','Yes'));
            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            false,'SignalType','complex'));
            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            false,'SamplingMode','Frame based'));
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
