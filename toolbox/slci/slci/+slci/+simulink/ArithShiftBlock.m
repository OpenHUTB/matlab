


classdef ArithShiftBlock<slci.simulink.Block

    methods

        function obj=ArithShiftBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'DiagnosticForOORShift','Error'));


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'BinPtShiftNumber','0'));


            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'int8','uint8','int16',...
            'uint16','int32','uint32'}));


            if(strcmpi(get_param(aBlk,'BitShiftNumberSource'),'Input port'))
                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraintWithFix(...
                false,'CheckOORBitShift','off'));
            end


            if(strcmpi(get_param(aBlk,'BitShiftNumberSource'),'Dialog'))
                obj.addConstraint(...
                slci.compatibility.ArithShiftOORShiftConstraint);
            end



            if(strcmpi(get_param(aBlk,'BitShiftNumberSource'),'Input port')&&...
                strcmpi(get_param(aBlk,'BitShiftDirection'),'Bidirectional'))
                obj.addConstraint(...
                slci.compatibility.ConstantPortConstraint('Inport',2));
            end

        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


