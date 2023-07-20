


classdef DelayBlock<slci.simulink.Block

    methods

        function obj=DelayBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'ShowEnablePort','off'));


            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            false,'InputProcessing',...
            'Columns as channels (frame based)'));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


