


classdef UnsupportedBlockTypeConstraint<slci.compatibility.Constraint

    methods(Access=protected)
        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)%#ok
            out='Some blocks are not supported.';
        end
    end

    methods
        function obj=UnsupportedBlockTypeConstraint()
            obj=obj@slci.compatibility.Constraint();
            obj.setEnum('UnsupportedBlocks');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            failure={};unsupportedBlocks={};
            unsupportedBlockObjs=aObj.ParentModel.getUnsupportedBlocks;
            for i=1:numel(unsupportedBlockObjs)
                unsupportedBlocks{end+1}=unsupportedBlockObjs{i}.getSID;%#ok<AGROW>
            end

            if~isempty(unsupportedBlocks)
                failure=slci.compatibility.Incompatibility(...
                aObj,'UnsupportedBlocks');
                failure.setObjectsInvolved(unsupportedBlocks);
            end
            out=failure;
        end

    end
end


