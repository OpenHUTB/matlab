

classdef SelectorBlock<slci.simulink.Block

    methods

        function obj=SelectorBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            pH=get_param(aBlk,'PortHandles');
            numInports=numel(pH.Inport);
            if(numInports==1)
                obj.addConstraint(...
                slci.compatibility.SelectorConstraint);

                obj.removeConstraint('BlockPortsMultiDim');
            else
                assert(numInports>1,'SelectorBlock compatibility check issue.');
                obj.addConstraint(slci.compatibility.NegativeBlockParameterConstraint(...
                false,'IndexOptionArray','Starting and ending indices (port)'));

                obj.addConstraint(...
                slci.compatibility.IndexPortDataTypeConstraint(...
                'Inport',(2:numInports),...
                {'int32','int16','int8','uint8','uint16','uint32'}));




                obj.addConstraint(...
                slci.compatibility.RangeSelectionConstraint(1));

                obj.removeConstraint('BlockPortsMultiDim');
            end

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
