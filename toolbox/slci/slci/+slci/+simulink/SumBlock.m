




classdef SumBlock<slci.simulink.Block

    methods

        function obj=SumBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.SumAccumDataTypeConstraint());
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);
            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single','int8','uint8','int16',...
            'uint16','int32','uint32'}));

            pH=get_param(aBlk,'PortHandles');
            numInports=numel(pH.Inport);

            if(numInports==1)
                obj.addConstraint(...
                slci.compatibility.SingleInputSumSaturationConstraint);
                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraint(...
                false,'CollapseMode','All dimensions'));
            end

        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


