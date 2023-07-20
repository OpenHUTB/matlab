


classdef ForEachDimensionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['For Each block input partition dimension and '...
            ,'output concatenate dimension should not be more than 2'];
        end


        function obj=ForEachDimensionConstraint()
            obj.setEnum('ForEachDimension');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            blk=aObj.ParentBlock();
            assert(isa(blk,'slci.simulink.ForEachBlock'));
            isSupported=aObj.checkDimension(blk.getInputPartitionDimension())...
            &&aObj.checkDimension(blk.getOutputConcatenationDimension());

            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end
    end

    methods(Access=private)


        function isSupported=checkDimension(~,dims)
            isSupported=true;
            for i=1:numel(dims)
                dim=dims(i);
                if(dim>2)
                    isSupported=false;
                    return;
                end
            end
        end
    end
end
