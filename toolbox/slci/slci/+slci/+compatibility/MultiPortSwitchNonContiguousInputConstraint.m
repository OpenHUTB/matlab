classdef MultiPortSwitchNonContiguousInputConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['For 2 inputs multiport switch, the 2nd input should'...
            ,'not be connected to a noncontiguous signal'];
        end

        function obj=MultiPortSwitchNonContiguousInputConstraint()
            obj.setEnum('MultiPortSwitchNonContiguousInput');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end





        function out=check(aObj)
            out=[];

            blkH=aObj.ParentBlock().getParam('Handle');
            actualSrcs=slci.internal.getActualSrc(blkH,1);
            inputNonContiguous=size(actualSrcs,1)>1;
            if inputNonContiguous
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MultiPortSwitchNonContiguousInput',...
                aObj.ParentBlock().getName());
            end
        end

    end
end
