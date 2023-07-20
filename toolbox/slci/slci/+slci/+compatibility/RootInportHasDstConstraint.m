

classdef RootInportHasDstConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='A root inport of a referenced model should connect to at least one non-virtual block, or else the inspection status for a model calling this model may be "warning"';
        end

        function obj=RootInportHasDstConstraint()
            obj.setEnum('RootInportHasDst');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];

            mdlObj=aObj.ParentModel();
            if mdlObj.getCheckAsRefModel()
                thisBlkHandle=aObj.ParentBlock().getParam('handle');
                dstBlock=slci.internal.getActualDst(thisBlkHandle,0);
                if isempty(dstBlock)
                    out=slci.compatibility.Incompatibility(aObj,'RootInportHasNoDstBlock');
                end
            end
        end

    end
end
