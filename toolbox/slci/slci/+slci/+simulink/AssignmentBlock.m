



classdef AssignmentBlock<slci.simulink.Block

    methods

        function obj=AssignmentBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            pH=get_param(aBlk,'PortHandles');
            numInports=numel(pH.Inport);

            if strcmpi(get_param(aBlk,'OutputInitialize'),...
                'Initialize using input port <Y0>')
                offset=3;
            else
                offset=2;
            end

            InportDataType=...
            slci.compatibility.IndexPortDataTypeConstraint('Inport',...
            offset:numInports,...
            {'int32','int16','int8','uint8','uint16','uint32'});
            obj.addConstraint(InportDataType);



            OutputInitializeConstraint=slci.compatibility.PositiveBlockParameterConstraint(...
            false,'OutputInitialize','Initialize using input port <Y0>');
            OutputInitializeConstraint.setHTMLEncode(true);
            obj.addConstraint(OutputInitializeConstraint);

            obj.removeConstraint('BlockPortsMultiDim');

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);

            obj.setSupportsEnumsForIndexPortDataType(true);
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


