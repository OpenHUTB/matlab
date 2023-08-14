


classdef TrigonometryBlock<slci.simulink.Block

    methods

        function obj=TrigonometryBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            false,'Operator','cos + jsin'));
            if strcmpi(get_param(aBlk,'Operator'),'cos')||...
                strcmpi(get_param(aBlk,'Operator'),'sin')||...
                strcmpi(get_param(aBlk,'Operator'),'atan2')||...
                strcmpi(get_param(aBlk,'Operator'),'sincos')||...
                strcmpi(get_param(aBlk,'Operator'),'cos + jsin')
                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraintWithFix(...
                false,'ApproximationMethod','none'));
            end
            if any(strcmpi(get_param(aBlk,'Operator'),{'acos','asin'}))
                obj.addConstraint(...
                slci.compatibility.NegativeBlockParameterConstraint(...
                true,'RemoveProtectionAgainstOutOfRangeInput','on'));
            end
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
