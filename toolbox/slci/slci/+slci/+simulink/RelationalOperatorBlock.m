


classdef RelationalOperatorBlock<slci.simulink.Block

    methods

        function obj=RelationalOperatorBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            opConstraint=slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'Operator','<=','==','>=','~=','<','>');
            opConstraint.setHTMLEncode(true);
            obj.addConstraint(opConstraint);
            obj.addConstraint(...
            slci.compatibility.SupportedOutPortDataTypesConstraint(...
            {'boolean'}));
            obj.addConstraint(...
            slci.compatibility.UniformInputPortDataTypesConstraint);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
