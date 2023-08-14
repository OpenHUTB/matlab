


classdef ForEachMaskParameterConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='For Each block mask parameter partition is not supported.';
        end


        function obj=ForEachMaskParameterConstraint()
            obj.setEnum('ForEachMaskParameter');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            maskPartition=aObj.ParentBlock().getParam('SubsysMaskParameterPartition');
            assert(iscell(maskPartition));
            supported=true;
            for i=1:numel(maskPartition)
                if strcmpi(maskPartition{i},'on')
                    supported=false;
                    break;
                end
            end

            if~supported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end

    end
end
